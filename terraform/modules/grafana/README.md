# Grafana Module
This is a terraform module used to install the GRAFANA application into the Government PaaS, and setting some of the configuration.

# Google Integration
By default the template now supports integration with google logins. The ID must be configured and passed in to support this, following the instructions [Google](https://grafana.com/docs/grafana/latest/auth/google/)

Grafana can be integrated with google single sign on.  This has a number of advantages. The main being there is no need to locally manage users.

## Google Configuration

- Navigate to the Google API Console
- Navigate to the Credentials Screen
- At the top of the screen click on the  link and choose OAuth Client ID from the pop-up list
- Enter **APPLICATION TYPE** as **WEB APPLICATION**
- Enter **NAME**, put in a unique name that identifies your project.
- Under the **AUTHORISED JAVASCRIPT AUTHORISATION**  field enter a list of URLs that your code uses. In our case we entered 
   - https://grafana-dev-get-into-teaching.london.cloudapps.digital
   - https://grafana-prod-get-into-teaching.london.cloudapps.digital
- Under the **AUTHORISED REDIRECT URIS**  field enter a list of feedback URLs, these are provided by Grafana, but in our case we used
   - http://grafana-dev-get-into-teaching.london.cloudapps.digital/login/google
   - http://grafana-dev-get-into-teaching.london.cloudapps.digital/login/google

That should be enough to configure Google.  You will be given a client_id and a client_secret which you will need to use in Grafana. These two fields can be read again if you return to the screen.

## Grafana Configuration

In your  file you need to enter the following variables:

```
[auth.google]
enabled = true
client_id = ${google_client_id}
client_secret = ${google_client_secret}
scopes = https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email
auth_url = https://accounts.google.com/o/oauth2/auth
token_url = https://accounts.google.com/o/oauth2/token
allowed_domains = digital.education.gov.uk
allow_sign_up = true
```

Note here, SET the allowed_domains or anyone with a google account can login

## Terraform configuration
```
locals {
  additional_variable_map = {
    ......
    google_client_id     = var.google_client_id
    google_client_secret = var.google_client_secret
      }
  }
 
  module "grafana" {
    source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/grafana?ref=master"
    ......
    additional_variable_map = local.additional_variable_map
}
```
Then all you need do is set your two keys as environment variables when you run the terraform.
```
export TF_VAR_google_client_id=827810668839-xxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
export TF_VAR_google_client_secret=XXXXXXXXXXXXXXXXXXXXXXX
```
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
