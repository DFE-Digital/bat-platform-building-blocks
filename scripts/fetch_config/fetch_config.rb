#!/usr/bin/env ruby
require 'getoptlong'
require 'logger'
require 'yaml'
require 'aws-sdk-ssm'
require 'erb'
require 'tempfile'

ALLOWED_SOURCES = ['aws-ssm-parameter', 'aws-ssm-parameter-path', 'yaml-file']
ALLOWED_DESTINATION = ['stdout', 'file', 'command', 'quiet']
ALLOWED_FORMATS = ['hash', 'shell-env-var', 'tf-shell-env-var', 'yaml', 'json']
EDITOR = 'vim'

@log = Logger.new(STDOUT)
@log.level = Logger::INFO

def usage
  puts <<~EOF
  Usage: fetch_config.sh [-v] -s type:locator [-s type:locator]... [-d type[:locator]] [-f format] [-- <command>]
  Arguments:
    -s (--source): Source of variables
      aws-ssm-parameter:<locator> aws-ssm-parameter name in AWS SSM Parameter store
      aws-ssm-parameter-path:<locator> parameter path in AWS SSM Parameter store hierarchy
      yaml-file:<locator> path to yaml file containing parameters
    -e (--edit): open editor to edit variables manually before output
    -d (--destination): Destination of variables
      stdout (default) : Write to standard out
      file:<path> : Write to file at <path>
      command : Run command in environment populated by the variables. Requires '-- <command>' at the end of the line
      quiet : No output (Validates input)
    -f (--format): Output format
      hash (default): Raw ruby hash {KEY => VALUE}
      shell-env-var: Standard shell environment variables KEY=VALUE (Not for nested variables)
      tf-shell-env-var: Terraform environment variables TF_VAR_KEY=VALUE (Not for nested variables)
      yaml: Yaml
      json: Raw json (single line)
    -v (--verbose): verbose output
  EOF
  @log.debug caller
  exit 1
end

def error_exit(message)
  @log.error message
  exit 2
end

def collect_source(arg)
  @log.debug "Extract source from #{arg}"
  source_type, source_locator = arg.split(':')
  usage unless ALLOWED_SOURCES.include? source_type
  usage unless source_locator
  new_source = {source_type => [source_locator]}
  @log.debug "Collecting #{new_source}"
  new_source
end

def extract_destination(arg)
  @log.debug "Extract destination from #{arg}"
  destination_type, destination_locator = arg.split(':')
  usage unless ALLOWED_DESTINATION.include? destination_type
  usage if destination_type == 'file' && ! destination_locator
  new_destination = {type: destination_type, locator: destination_locator}
  @log.debug "Found destination #{new_destination}"
  new_destination
end

def run_command_with_env(config_map, command)
  @log.debug 'Running command: ' + command
  ENV.update(config_map)
  exec command
end

def pull_ssm_parameters(parameters)
  @log.debug 'Fetching parameters ' + parameters.to_s
  return {} unless parameters
  config_map = {}
  ssm_client = Aws::SSM::Client.new(region: 'eu-west-2')

  parameters.each { |parameter_path|
    response = ssm_client.get_parameter({
      name: parameter_path,
      with_decryption: true,
    })
    parameter_map = YAML.load(response.parameter.value)
    begin
      config_map.update parameter_map
    rescue TypeError => e
      puts "Error: Syntax error in AWS SSM parameter " + parameter_path
      raise e
    end
  }

  config_map
end

def pull_ssm_parameter_paths(parameter_paths)
  @log.debug 'Fetching parameters in paths ' + parameter_paths.to_s
  return {} unless parameter_paths
  config_map = {}
  ssm_client = Aws::SSM::Client.new(region: 'eu-west-2')

  parameter_paths.each { |parameter_path|
    response = ssm_client.get_parameters_by_path({
      path: parameter_path,
      recursive: true,
      with_decryption: true
    })
    response.parameters.each { |parameter|
      begin
        parameter_map = YAML.load(parameter.value)
        config_map.update parameter_map
      rescue TypeError => e
        puts "Error: Syntax error in AWS SSM parameter " + parameter.name
        raise e
      end
    }
  }

  config_map
end

def read_from_yaml_files(yaml_files)
  @log.debug 'Fetching parameters from files ' + yaml_files.to_s
  return {} unless yaml_files
  config_map = {}

  yaml_files.each{ |yaml_file|
    begin
      parameter_map = YAML.load_file(yaml_file)
    rescue Psych::SyntaxError => e
      puts "Error: Syntax error in file " + yaml_file
      raise e
    end
    config_map.update parameter_map
  }

  config_map
end

def make_tf_vars_map(config_map)
  @log.debug 'Transforming variables into terraform TF_VAR_* variables'

  config_map.map { |k, v| ["TF_VAR_#{k}", v] }.to_h
end

def stringify(config_map)
  @log.debug 'Converting non string values to strings'

  config_map.map { |k, v|
    if v.is_a?(Hash) || v.is_a?(Array)
      error_exit "Error: This format does not accept nested variables: #{k}: #{v}"
    end
    v = v.to_s unless v.is_a? String
    [k, v]
  }.to_h
end

def sort_by_key(config_map)
  config_map.sort.to_h
end

def env_var_list(config_map)
  shell_template = <<~EOF
  <% for k,v in config_map %><%= k %>=<%= v %>
  <% end %>
  EOF
  erb = ERB.new shell_template

  erb.result
end

def open_in_editor(config_map)
  new_map = {}
  Tempfile.create { |f|
    YAML.dump(config_map, f)
    f.rewind
    @log.debug "Opening file #{f.path} with editor: #{EDITOR}"
    system(EDITOR, f.path)
    new_map = YAML.load_file(f.path)
  }
  new_map
end

##### Configuration #####
opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--source', '-s', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--edit', '-e', GetoptLong::NO_ARGUMENT ],
  [ '--destination', '-d', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--format', '-f', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--verbose', '-v', GetoptLong::NO_ARGUMENT ]
)

sources = {}
edit = false
destination = nil
output_format = nil
command = nil

opts.each do |opt, arg|
  case opt
  when '--help'
    usage
  when '--source'
    sources.update(collect_source(arg)){ |k, v1, v2|
      @log.debug "Appending #{v2} to #{v1}"
      v1 + v2
    }
  when '--edit'
    edit = true
  when '--destination'
    destination = extract_destination(arg)
  when '--format'
    usage unless ALLOWED_FORMATS.include? arg
    output_format = arg
  when '--verbose'
    @log.level = Logger::DEBUG
  end
end

##### Validation #####
usage if sources.empty?

destination = {type: 'stdout'} unless destination

if destination[:type] == 'command'
  command = ARGV.join(' ')
  usage unless command != ''
  destination[:command] = command
end

##### Pull data #####
config_map = {}

config_map.update(pull_ssm_parameters sources['aws-ssm-parameter'])
config_map.update(pull_ssm_parameter_paths sources['aws-ssm-parameter-path'])
config_map.update(read_from_yaml_files sources['yaml-file'])

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

##### Output #####
case destination[:type]
when 'stdout'
  puts output_string
when 'file'
  File.write(destination[:locator], output_string)
when 'command'
  run_command_with_env(config_map, destination[:command])
end
