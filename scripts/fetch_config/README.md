## Fetch config

Script to fetch config and secrets stored in yaml from different sources and output them to a destination with a chosen format.

### Requirements

- Ruby (tested with 2.6.6)
- Run `bundle` to install the dependencies
- Permission to access the sources. Example in the case of AWS, the credentials must be configured as per: [Configuring the AWS SDK for Ruby](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html).

### Print help
```
$ ./fetch_config.rb -h
```

### Read from one SSM parameter (raw output)
```
$ ./fetch_config.rb -s aws-ssm-parameter:/path/to/parameter
```

### Read from Yaml file and SSM paramether hierarchy (raw output)
```
$ ./fetch_config.rb -s aws-ssm-parameter-path:/path/to/parameter/hierarchy -s yaml-file:path/to/file.yml
```

### Output SSM parameter to file as shell environment variables
```
$ ./fetch_config.rb -s aws-ssm-parameter:/path/to/param -d file:path/to/output_file.sh -f shell-env-var
```

### Output SSM parameter to file as json
```
$ ./fetch_config.rb -s aws-ssm-parameter:/path/to/param -d file:path/to/output_file.json -f json
```

### Fetch SSM parameter and run command in environment populated with the variables
```
$ ./fetch_config.rb -s aws-ssm-parameter:/path/to/param -d command -f shell-env-var -- rails server
```

### Fetch SSM parameter and edit it on the fly before output
```
$ ./fetch_config.rb -s aws-ssm-parameter:/path/to/param -e -d file:path/to/output_file.sh -f shell-env-var
```
