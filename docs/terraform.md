# Terraform modules

The modules can be referenced from terraform code in other repositories.
Example:

```hcl
module prometheus_all {
  source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/prometheus_all?ref=dev"

  name = var.name
  space_id = data.cloudfoundry_space.monitoring.id
  paas_exporter_username = var.paas_exporter_username
  paas_exporter_password = var.paas_exporter_password
  alertmanager_config = file("${path.module}/files/alertmanager.yml")
  grafana_admin_password = var.grafana_admin_password
}
```

* paas_prometheus_exporter: Deploys the paas_prometheus_exporter app to read paas metrics. It must be configured with a user which has at least SpaceAuditor role.
* alertmanager: Deploys the alertmanager app. The config file is passed as parameter.
* influxdb: Deploys the influxdb time series database so that prometheus can persist the metrics
* prometheus: Deploys the prometheus app. It binds to influxdb to store the metrics. It requires alertmanager and paas_prometheus_exporter to be installed so the endpoints can be configured in prometheus.
* grafana: Deploys the grafana app to display dashboards. The admin password is passed as parameter.
* prometheus_all: Module deploying all other monitoring modules. It is there for convenience and should be enough for most cases.

