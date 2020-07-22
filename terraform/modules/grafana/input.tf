variable space_id {}
variable name {}
variable prometheus_endpoint {}
variable admin_password {}

variable additional_variable_map{
  type = map
  default = {
     do_nothing = "Nothing"
  }
}

variable configuration_file {
    default = ""
}

variable dashboard_directory {
    default = ""
}

variable datasource_directory {
    default = ""
}

variable plugins_file {
    default = ""
}

locals {
  template_variable_map = {
    prometheus_endpoint = var.prometheus_endpoint
    name                = var.name
  }
}
