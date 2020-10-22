# Grafana Module
This is a terraform module used to install the GRAFANA application into the Government PaaS, and setting some of the configuration.

# Google Integration
By default the template now supports integration with google logins. The ID must be configured and passed in to support this, following the instructions [Google](https://grafana.com/docs/grafana/latest/auth/google/)

### Inputs
```space_id               MANDATORY
   name                   MANDATORY
   prometheus_endpoint    MANDATORY
   admin_password         MANDATORY

   additional_variable_map OPTIONAL
   dashboard_directory     OPTIONAL 
   datasource_directory    OPTIONAL
   configuration_file      OPTIONAL
   plugins_list            OPTIONAL
   runtime_version         OPTIONAL
```

### Plugins List
Is a file containing a list of plugins in the format of:
```
grafana-piechart-panel
grafana-clock-panel
```


### Additional Variables 
Additional variables are used in the mapping of templates. 

### Example Usage
```
module "grafana" {
     source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/grafana?ref=master"

     space_id                = data.cloudfoundry_space.space.id
     name                    = "Graphana"
     admin_password          = "xxxxx"
     dashboard_directory     = local.dashboard_directory
     datasource_directory    = local.datasource_directory
     prometheus_endpoint     = "https://prometheus.london.cloudapps.digital"
     additional_variable_map = local.map
}
```

