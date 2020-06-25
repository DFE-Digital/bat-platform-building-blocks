module paas_prometheus_exporter {
  source = "../paas_prometheus_exporter"

  name     = var.name
  space_id = var.space_id
  username = var.paas_exporter_username
  password = var.paas_exporter_password
}

module influxdb {
  source = "../influxdb"

  name     = var.name
  space_id = var.space_id
}

module prometheus {
  source = "../prometheus"

  name                              = var.name
  space_id                          = var.space_id
  paas_prometheus_exporter_endpoint = module.paas_prometheus_exporter.endpoint
  alertmanager_endpoint             = module.alertmanager.endpoint
  alert_rules                       = var.alert_rules
}

module alertmanager {
  source = "../alertmanager"

  name     = var.name
  space_id = var.space_id
  config   = var.alertmanager_config
}

module grafana {
  source = "../grafana"

  name                = var.name
  space_id            = var.space_id
  prometheus_endpoint = module.prometheus.endpoint
  admin_password      = var.grafana_admin_password
  json_dashboards     = var.grafana_json_dashboards
}
