variable monitoring_instance_name {}

variable monitoring_space_id {}

variable prometheus_endpoint {}

variable runtime_version { default = "6.5.1" }

variable google_client_id { default = "" }
variable google_client_secret { default = "" }
variable admin_password {}
variable json_dashboards { default = [] }
variable extra_datasources { default = [] }

locals {
  grafana_ini_variables = {
    google_client_id     = var.google_client_id
    google_client_secret = var.google_client_secret
  }
  prometheus_datasource_variables = {
    prometheus_endpoint      = var.prometheus_endpoint
    monitoring_instance_name = var.monitoring_instance_name
  }
}
