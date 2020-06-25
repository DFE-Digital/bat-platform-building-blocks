variable space_id {}
variable name {}
variable paas_prometheus_exporter_endpoint {}
variable alertmanager_endpoint {}
variable alert_rules {
  default = ""
}

locals {
  template_variable_map = {
    paas_prometheus_exporter_endpoint = var.paas_prometheus_exporter_endpoint
    alertmanager_endpoint             = var.alertmanager_endpoint
    name                              = var.name
  }
}
