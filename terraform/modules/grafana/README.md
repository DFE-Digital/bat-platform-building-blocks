## Grafana Module
This is a terraform module used to install the [grafana](https://grafana.com/) application into the Government PaaS, and setting some of the configuration.

It is deployed using the [Springer grafana buildpack](https://github.com/SpringerPE/cf-grafana-buildpack).

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
```monitoring_space_id       MANDATORY
   mionitoring_instance_name MANDATORY
   prometheus_endpoint       MANDATORY
   admin_password            MANDATORY

   runtime_version           OPTIONAL
   google_client_id          OPTIONAL
   google_client_secret      OPTIONAL
   json_dashboards           OPTIONAL
   extra_datasources         OPTIONAL
```

### Datasources
The default prometheus datasource is already preconfigured.

Additional [data sources](https://grafana.com/docs/grafana/latest/datasources/) can be added via the `extra_datasources` input. It represents a list of datasources, each one being the string content of the yaml datasource file.

### Dashboards
Dashboards can be automatically loaded thanks to the `json_dashboards` variable. It represents a list of dashboards, each one being the string content of the json dashboard file, as exported by grafana.

### Plugins List
The following plugins are included. They are listed in the `plugins.txt` file:
```
grafana-piechart-panel
aidanmountford-html-panel
simpod-json-datasource
```

### Google Integration
Grafana supports integration with google logins. The ID must be configured and passed in to support this, following the [grafana instructions](https://grafana.com/docs/grafana/latest/auth/google/).

### Runtime version
The default version is 6.5.1. It has been tested successfully with version 7.

### Example Usage
```
module "grafana" {
     source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/grafana?ref=master"

     monitoring_space_id      = data.cloudfoundry_space.space.id
     monitoring_instance_name = "Graphana"
     admin_password           = "xxxxx"
     json_dashboards          = [
        file("${path.module}/dashboards/frontend.json)",
        file("${path.module}/dashboards/backend.json)"
      ]
     extra_datasources        = [file("${path.module}/datasources/elasticsearch.yml)",
     prometheus_endpoint      = "https://prometheus.london.cloudapps.digital"
     runtime_version          = "x.x.x"
}
```
