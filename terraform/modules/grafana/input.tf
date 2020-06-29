variable space_id {}
variable name {}
variable prometheus_endpoint {}
variable admin_password {}
variable json_dashboards {
  type    = list
  default = []
}

locals {
  template_variable_map = {
    prometheus_endpoint = var.prometheus_endpoint
    name                = var.name
  }
}
