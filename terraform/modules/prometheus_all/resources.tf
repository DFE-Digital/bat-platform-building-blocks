module paas_prometheus_exporter {
  source = "../paas_prometheus_exporter"
  count  = contains(var.enabled_modules, "paas_prometheus_exporter") ? 1 : 0

  monitoring_instance_name = var.monitoring_instance_name
  monitoring_space_id      = data.cloudfoundry_space.monitoring.id
  paas_username            = var.paas_exporter_username
  paas_password            = var.paas_exporter_password
}

module influxdb {
  source = "../influxdb"
  count  = contains(var.enabled_modules, "influxdb") ? 1 : 0

  monitoring_instance_name = var.monitoring_instance_name
  monitoring_space_id      = data.cloudfoundry_space.monitoring.id
}

module prometheus {
  source = "../prometheus"
  count  = contains(var.enabled_modules, "prometheus") ? 1 : 0

  monitoring_instance_name          = var.monitoring_instance_name
  monitoring_space_id               = data.cloudfoundry_space.monitoring.id
  paas_prometheus_exporter_endpoint = module.paas_prometheus_exporter[0].endpoint
  influxdb_service_instance_id      = module.influxdb[0].service_instance_id
  alertmanager_endpoint             = contains(var.enabled_modules, "alertmanager") ? module.alertmanager[0].endpoint : ""
  alert_rules                       = var.alert_rules
  memory                            = var.prometheus_memory
  disk_quota                        = var.prometheus_disk_quota
}

module alertmanager {
  source = "../alertmanager"
  count  = contains(var.enabled_modules, "alertmanager") ? 1 : 0

  monitoring_instance_name = var.monitoring_instance_name
  monitoring_space_id      = data.cloudfoundry_space.monitoring.id
  config                   = var.alertmanager_config
  slack_url                = var.alertmanager_slack_url
  slack_channel            = var.alertmanager_slack_channel
}

module grafana {
  source = "../grafana"
  count  = contains(var.enabled_modules, "grafana") ? 1 : 0

  monitoring_instance_name = var.monitoring_instance_name
  monitoring_space_id      = data.cloudfoundry_space.monitoring.id
  prometheus_endpoint      = module.prometheus[0].endpoint
  google_client_id         = var.grafana_google_client_id
  google_client_secret     = var.grafana_google_client_secret
  admin_password           = var.grafana_admin_password
  json_dashboards          = var.grafana_json_dashboards
  extra_datasources        = var.grafana_extra_datasources
  influxdb_credentials     = module.influxdb[0].credentials
}
