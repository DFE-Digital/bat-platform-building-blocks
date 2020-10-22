variable monitoring_org_name {}

variable monitoring_space_id {}

variable graphana_admin_password {}

variable prometheus_endpoint {}

variable configuration_file { default = "" }

variable plugins_file { default = "" }

variable dashboard_directory { default = "" }

variable datasource_directory { default = "" }

variable runtime_version  { default = "6.5.1" }

locals {
  tmp_data   = var.datasource_directory == "" ? "${path.module}/datasources/" : var.datasource_directory
  tmp_dash   = var.dashboard_directory == "" ? "${path.module}/dashboards/" : var.dashboard_directory
  tmp_plug   = var.plugins_file == "" ? "${path.module}/config/plugins.txt" : var.plugins_file
  tmp_config = var.configuration_file == "" ? "${path.module}/config/grafana.ini" : var.configuration_file

  tmp_runtime = "${path.module}/config/runtime.txt"

  dashboards  = fileset("${local.tmp_dash}", "*.json")
  datasources = fileset("${local.tmp_data}", "*.yml.tmpl")
  plugins     = fileset("${local.tmp_plug}", "*.zip")

}

variable additional_variable_map {
  type = map
  default = {
    do_nothing = "Nothing"
  }
}

locals {
  template_variable_map = {
    prometheus_endpoint        = var.prometheus_endpoint
    prometheus_datasource_name = "prometheus-${var.monitoring_org_name}"
  }
}
