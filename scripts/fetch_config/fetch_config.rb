#!/usr/bin/env ruby

require 'getoptlong'
require 'logger'
require 'yaml'
require 'erb'
require 'tempfile'
require 'net/http'
require 'json'
require 'shellwords'
require 'English'

ALLOWED_SOURCES = ['aws-ssm-parameter', 'aws-ssm-parameter-path', 'yaml-file', 'azure-key-vault-secret'].freeze
ALLOWED_DESTINATION = ['stdout', 'file', 'command', 'quiet', 'azure-key-vault-secret'].freeze
ALLOWED_FORMATS = ['hash', 'shell-env-var', 'tf-shell-env-var', 'yaml', 'json'].freeze
EDITOR = ENV.fetch('VISUAL', ENV.fetch('EDITOR', 'vi'))

@log = Logger.new(STDOUT)
@log.level = Logger::INFO

def usage
  puts <<~HELP
    Usage: fetch_config.sh [-v] -s type:<locator> [-s type:<locator>]... [-d type[<locator>]] [-f format] [-- <command>]
    Arguments:
      -s (--source): Source of variables
        aws-ssm-parameter:<parameter-name> aws-ssm-parameter name in AWS SSM Parameter store
        aws-ssm-parameter-path:<parameter-path> parameter path in AWS SSM Parameter store hierarchy
        yaml-file:<path> path to yaml file containing parameters
        azure-key-vault-secret[:<keyvault-name/secret-name>] secret in Azure key vault
        if keyvault-name and secret-name are not specified, the values are read from 'key_vault_name' and 'key_vault_app_secret_name' environment variables
      -e (--edit): open editor to edit variables manually before output
      -d (--destination): Destination of variables
        stdout (default) : Write to standard out
        file:<path> : Write to file at <path>
        command : Run command in environment populated by the variables. Requires '-- <command>' at the end of the line
        quiet : No output (Validates input)
        azure-key-vault-secret[:<keyvault-name/secret-name>] : Secret in Azure key vault
        if keyvault-name and secret-name are not specified, the values are read from 'key_vault_name' and 'key_vault_app_secret_name' environment variables
      -f (--format): Output format
        hash (default): Raw ruby hash {KEY => VALUE}
        shell-env-var: Standard shell environment variables KEY=VALUE (Not for nested variables)
        tf-shell-env-var: Terraform environment variables TF_VAR_KEY=VALUE (Not for nested variables)
        yaml: Yaml
        json: Raw json (single line)
      -i (--ignore-missing-source): Ignore missing sources
      -c (--confirm): Ask for confirmation before writing to destination
      -v (--verbose): verbose output
  HELP
  @log.debug caller
  exit 1
end

def error_exit(message)
  @log.error message
  exit 2
end

def collect_source(arg)
  @log.debug "Extract source from #{arg}"
  source_type, source_parameter = arg.split(':')
  usage unless ALLOWED_SOURCES.include? source_type
  source_parameter = "#{ENV['key_vault_name']}/#{ENV['key_vault_app_secret_name']}" if source_parameter.nil? && source_type == 'azure-key-vault-secret'
  usage unless source_parameter
  new_source = { source_type => [source_parameter] }
  @log.debug "Collecting #{new_source}"
  new_source
end

def extract_destination(arg)
  @log.debug "Extract destination from #{arg}"
  destination_type, destination_parameter = arg.split(':')
  usage unless ALLOWED_DESTINATION.include? destination_type
  usage if !destination_parameter && destination_type == 'file'
  destination_parameter = "#{ENV['key_vault_name']}/#{ENV['key_vault_app_secret_name']}" if destination_parameter.nil? && destination_type == 'azure-key-vault-secret'
  @log.debug "destination_parameter is #{destination_parameter}"
  new_destination = { type: destination_type, parameter: destination_parameter }
  @log.debug "Found destination #{new_destination}"
  new_destination
end

def run_command_with_env(config_map, command)
  @log.debug "Running command: #{command}"
  ENV.update(config_map)
  exec command
end

def push_to_azure_key_vault_secret(output_string, azure_key_vault_secret)
  secret_expiry = DateTime.now.next_year(2).strftime("%FT%T.%LZ")
  @log.debug "Updating Azure key vault secrets #{azure_key_vault_secret} with expiry #{secret_expiry}"
  key_vault_access_token = key_vault_token

  key_vault, secret_name = azure_key_vault_secret.split('/')
  vault_base_url = "https://#{key_vault}.vault.azure.net"

  uri = URI("#{vault_base_url}/secrets/#{secret_name}?api-version=7.1")
  body = { 'value' => output_string, 'exp' => secret_expiry }.to_json

  req = Net::HTTP::Put.new(uri)
  req['Authorization'] = "Bearer #{key_vault_access_token}"
  req['Content-type'] = 'application/json'
  req.body = body

  res = Net::HTTP.start(uri.hostname, uri.port, { use_ssl: uri.scheme == 'https' }) do |http|
    http.request(req)
  end

  if res.is_a? Net::HTTPSuccess
    @log.debug "Secret #{secret_name} updated successfully in key vault #{key_vault}"
  else
    message = "Failed updating secret #{secret_name} in key vault #{key_vault}. "
    message << "Response: #{res.code} #{Net::HTTPResponse::CODE_TO_OBJ[res.code]} #{res.body}"
    raise message
  end
end

def pull_ssm_parameters(parameters)
  return {} unless parameters

  require 'aws-sdk-ssm'
  @log.debug "Fetching parameters #{parameters}"
  config_map = {}
  ssm_client = Aws::SSM::Client.new(region: 'eu-west-2')

  parameters.each do |parameter_path|
    response = ssm_client.get_parameter({
      name: parameter_path,
      with_decryption: true,
    })
    parameter_map = YAML.load(response.parameter.value)
    begin
      config_map.update parameter_map
    rescue TypeError => e
      puts "Error: Syntax error in AWS SSM parameter #{parameter_path}"
      raise e
    end
  end
  config_map
end

def pull_ssm_parameter_paths(parameter_paths)
  return {} unless parameter_paths

  require 'aws-sdk-ssm'
  @log.debug "Fetching parameters in paths #{parameter_paths}"
  config_map = {}
  ssm_client = Aws::SSM::Client.new(region: 'eu-west-2')

  parameter_paths.each do |parameter_path|
    response = ssm_client.get_parameters_by_path({
      path: parameter_path,
      recursive: true,
      with_decryption: true,
    })
    response.parameters.each do |parameter|
      parameter_map = YAML.load(parameter.value)
      config_map.update parameter_map
    rescue TypeError => e
      puts "Error: Syntax error in AWS SSM parameter #{parameter.name}"
      raise e
    end
  end

  config_map
end

def read_from_yaml_files(yaml_files)
  return {} unless yaml_files

  @log.debug "Fetching parameters from files #{yaml_files}"
  config_map = {}

  yaml_files.each do |yaml_file|
    begin
      parameter_map = YAML.load_file(yaml_file)
    rescue Psych::SyntaxError => e
      puts "Error: Syntax error in file #{yaml_file}"
      raise e
    end
    config_map.update parameter_map
  end

  config_map
end

def key_vault_token
  token_json = `az account get-access-token -o json --resource https://vault.azure.net`
  raise 'az account get-access-token failed' if $CHILD_STATUS != 0

  JSON.parse(token_json)['accessToken']
end

def pull_azure_key_vault_secret(azure_key_vault_secrets, ignore_missing_source)
  return {} unless azure_key_vault_secrets

  @log.debug "Fetching Azure key vault secrets #{azure_key_vault_secrets}"
  key_vault_access_token = key_vault_token
  config_map = {}

  azure_key_vault_secrets.each do |azure_key_vault_secret|
    key_vault, secret_name = azure_key_vault_secret.split('/')
    vault_base_url = "https://#{key_vault}.vault.azure.net"

    uri = URI("#{vault_base_url}/secrets/#{secret_name}?api-version=7.1")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{key_vault_access_token}"
    res = Net::HTTP.start(uri.hostname, uri.port, { use_ssl: uri.scheme == 'https' }) do |http|
      http.request(req)
    end

    secret_hash = process_azure_response(res, ignore_missing_source)
    next if secret_hash.nil?

    begin
      secret_value = secret_hash['value']
      parameter_map = YAML.load(secret_value)
    rescue Psych::SyntaxError => e
      puts "Error: Syntax error in Azure key vault secret #{azure_key_vault_secret}"
      raise e
    end

    config_map.update parameter_map
  end

  config_map || nil
end

def process_azure_response(res, ignore_missing_source)
  json_response = JSON.parse(res.body)

  case res
  when Net::HTTPNotFound

    if ignore_missing_source
      @log.debug('Recieved a HTTPNotFound response. Continuing')
      nil
    else
      raise "#{res.code} #{Net::HTTPResponse::CODE_TO_OBJ[res.code]}\n#{json_response['error']['message']}\nIf you are trying to create a new secret then you will need to use the -i flag to ignore missing source secrets!"
    end
  when !Net::HTTPSuccess
    @log.error("An error occured while processing the request: #{json_response['error']['code']}\n#{json_response['error']['message']}")
    raise 'Azure response contained error'
  else
    json_response
  end
end

def make_tf_vars_map(config_map)
  @log.debug 'Transforming variables into terraform TF_VAR_* variables'

  config_map.transform_keys { |k| ["TF_VAR_#{k}", config_map[k]] }
end

def stringify(config_map)
  @log.debug 'Converting non string values to strings'

  config_map.transform_keys do |k,v|
    if config_map[v].is_a?(Hash) || config_map[v].is_a?(Array)
      error_exit "Error: This format does not accept nested variables: #{k}: #{config_map(v)}"
    end
    v = config_map[v].to_s unless v.is_a? String
    [k, v]
  end
end

def sort_by_key(config_map)
  config_map.sort.to_h
end

def env_var_list(config_map)
  shell_template = <<~TEMPLATE
    <% for k,v in config_map %><%= k %>=<%= v %>
    <% end %>
  TEMPLATE
  erb = ERB.new shell_template

  erb.result
end

def open_in_editor(config_map)
  new_map = {}
  value = config_map.empty? ? nil : config_map
  Tempfile.create do |f|
    YAML.dump(value, f)
    f.rewind
    cmd = "#{EDITOR} #{Shellwords.escape(f.path)}"
    @log.debug "Editing config file: #{cmd}"
    raise "Editor error: #{$CHILD_STATUS}" unless system(cmd)

    new_map = YAML.load_file(f.path)
  end
  new_map
end

def ask_to_confirm(destination, output_string)
  puts "About to write the following to #{destination[:type]} #{destination[:parameter]}"
  puts '################################################################################'
  puts output_string
  puts '################################################################################'
  print "Enter 'yes' to confirm: "
  answer = gets.chomp
  if answer != 'yes'
    puts 'Cancelled'
    exit
  end
end

##### Configuration #####
opts = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT],
  ['--source', '-s', GetoptLong::REQUIRED_ARGUMENT],
  ['--edit', '-e', GetoptLong::NO_ARGUMENT],
  ['--destination', '-d', GetoptLong::OPTIONAL_ARGUMENT],
  ['--format', '-f', GetoptLong::REQUIRED_ARGUMENT],
  ['--ignore-missing-source', '-i', GetoptLong::OPTIONAL_ARGUMENT],
  ['--confirm', '-c', GetoptLong::NO_ARGUMENT],
  ['--verbose', '-v', GetoptLong::NO_ARGUMENT],
)

sources = {}
edit = false
destination = nil
output_format = nil
ignore_missing_source = false
confirm = false

opts.each do |opt, arg|
  case opt
  when '--help'
    usage
  when '--source'
    sources.update(collect_source(arg)) do |_, v1, v2|
      @log.debug "Appending #{v2} to #{v1}"
      v1 + v2
    end
  when '--edit'
    edit = true
  when '--destination'
    destination = extract_destination(arg)
  when '--format'
    usage unless ALLOWED_FORMATS.include? arg
    output_format = arg
  when '--ignore-missing-source'
    ignore_missing_source = true
  when '--confirm'
    confirm = true
  when '--verbose'
    @log.level = Logger::DEBUG
  end
end

@log.level = Logger::DEBUG if ENV['FETCH_CONFIG_VERBOSE']

##### Validation #####
usage if sources.empty?

destination ||= { type: 'stdout' }

if destination[:type] == 'command'
  command = ARGV.join(' ')
  usage unless command != ''
  destination[:parameter] = command
end

##### Pull data #####
config_map = {}

config_map.update((pull_ssm_parameters sources['aws-ssm-parameter']))
config_map.update((pull_ssm_parameter_paths sources['aws-ssm-parameter-path']))
config_map.update((read_from_yaml_files sources['yaml-file']))
azure_key_vault_map = pull_azure_key_vault_secret(sources['azure-key-vault-secret'], ignore_missing_source)
config_map.update(azure_key_vault_map)

##### Transform #####
config_map = sort_by_key(config_map)
config_map = open_in_editor(config_map) if edit

@log.debug "Configuration: #{config_map}"

case output_format
when 'shell-env-var'
  config_map = stringify(config_map)
  output_string = env_var_list(config_map)
when 'tf-shell-env-var'
  config_map = make_tf_vars_map config_map
  config_map = stringify(config_map)
  output_string = env_var_list(config_map)
when 'yaml'
  output_string = YAML.dump(config_map)
when 'json'
  output_string = JSON.dump(config_map)
else
  output_string = config_map.to_s
end

##### Confirm #####
ask_to_confirm(destination, output_string) if confirm

##### Output #####
case destination[:type]
when 'stdout'
  puts output_string
when 'file'
  File.write(destination[:parameter], output_string)
when 'command'
  run_command_with_env(config_map, destination[:parameter])
when 'azure-key-vault-secret'
  push_to_azure_key_vault_secret(output_string, destination[:parameter])
end
