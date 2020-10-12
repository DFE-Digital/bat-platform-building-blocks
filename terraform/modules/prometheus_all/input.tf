variable monitoring_org_name {}

variable monitoring_space_name {}

variable paas_user {}

variable paas_password {}

variable paas_sso_code {}

variable grafana_admin_password {}

variable alertmanager_config { default = "" }

variable alert_rules { default = "" }

variable paas_exporter_config {
  type = map
  default = {
    API_ENDPOINT = ""
    USERNAME     = ""
    PASSWORD     = ""
  }
}

variable grafana_config {
  type = map
  default = {
    dashboard_directory  = "../grafana/dashboards"
    datasource_directory = "../grafana/datasources"
    configuration_file   = "../grafana/config/grafana.ini"
  }
}

variable enabled_modules {
  type = list
  default = [
    "paas_prometheus_exporter",
    "postgres_prometheus_exporter",
    "redis_prometheus_exporter",
    "prometheus",
    "grafana",
    "alertmanager"
  ]
}

locals {
  paas_api_url = "https://api.london.cloud.service.gov.uk"

  grafana_config = {
    dashboard_directory  = lookup(var.grafana_config, "dashboard_directory", "../grafana/dashboards")
    datasource_directory = lookup(var.grafana_config, "datasource_directory", "../grafana/datasources")
    configuration_file   = lookup(var.grafana_config, "configuration_file", "../grafana/config/grafana.ini")

    google_client_id     = lookup(var.grafana_config, "google_client_id", "")
    google_client_secret = lookup(var.grafana_config, "google_client_secret", "")
  }
}
