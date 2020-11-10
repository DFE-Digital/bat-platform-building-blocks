## Grafana Module
This is a terraform module used to install the [grafana](https://grafana.com/) application into the Government PaaS, and setting some of the configuration.

It is deployed using the [Springer grafana buildpack](https://github.com/SpringerPE/cf-grafana-buildpack).

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
