module paas_prometheus_exporter {
  source = "../paas_prometheus_exporter"
  count  = contains(var.enabled_modules, "paas_prometheus_exporter") ? 1 : 0

  monitoring_org_name      = var.monitoring_org_name
  monitoring_space_id      = data.cloudfoundry_space.monitoring.id
  environment_variable_map = var.paas_exporter_config
}

module influxdb {
  source = "../influxdb"
  count  = contains(var.enabled_modules, "prometheus") ? 1 : 0

  monitoring_org_name = var.monitoring_org_name
  monitoring_space_id = data.cloudfoundry_space.monitoring.id
}

module prometheus {
  source = "../prometheus"
  count  = contains(var.enabled_modules, "prometheus") ? 1 : 0

  monitoring_org_name               = var.monitoring_org_name
  monitoring_space_id               = data.cloudfoundry_space.monitoring.id
  paas_prometheus_exporter_endpoint = module.paas_prometheus_exporter[0].endpoint
  influxdb_service_instance_id      = module.influxdb[0].service_instance_id
  alertmanager_endpoint             = contains(var.enabled_modules, "alertmanager") ? module.alertmanager[0].endpoint : ""
  alert_rules                       = var.alert_rules

  depends_on = [module.influxdb]
}

module alertmanager {
  source = "../alertmanager"
  count  = contains(var.enabled_modules, "alertmanager") ? 1 : 0

  monitoring_org_name = var.monitoring_org_name
  monitoring_space_id = data.cloudfoundry_space.monitoring.id
  config              = var.alertmanager_config
}

module grafana {
  source = "../grafana"
  count  = contains(var.enabled_modules, "grafana") ? 1 : 0

  monitoring_org_name     = var.monitoring_org_name
  monitoring_space_id     = data.cloudfoundry_space.monitoring.id
  prometheus_endpoint     = module.prometheus[0].endpoint
  graphana_admin_password = var.grafana_admin_password
  dashboard_directory     = local.grafana_config["dashboard_directory"]

  additional_variable_map = {
    google_client_id     = local.grafana_config["google_client_id"]
    google_client_secret = local.grafana_config["google_client_secret"]
  }
}
