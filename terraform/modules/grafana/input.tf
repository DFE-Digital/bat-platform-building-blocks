variable monitoring_instance_name {}

variable monitoring_space_id {}

variable prometheus_endpoint {}

variable runtime_version { default = "6.5.1" }

variable google_client_id { default = "" }
variable google_client_secret { default = "" }
variable influxdb_credentials { default = "" }

variable admin_password {}
variable json_dashboards { default = [] }
variable extra_datasources { default = [] }

locals {
  dashboard_list = fileset(path.module, "dashboards/*.json")
  dashboards     = [for f in local.dashboard_list : file("${path.module}/${f}")]
  grafana_ini_variables = {
    google_client_id     = var.google_client_id
    google_client_secret = var.google_client_secret
  }
  prometheus_datasource_variables = {
    prometheus_endpoint      = var.prometheus_endpoint
    monitoring_instance_name = var.monitoring_instance_name
    influxdb_hostname        = var.influxdb_credentials.hostname
    influxdb_port            = var.influxdb_credentials.port
    influxdb_username        = var.influxdb_credentials.username
    influxdb_password        = var.influxdb_credentials.password
  }
}
