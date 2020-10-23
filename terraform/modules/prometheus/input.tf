variable space_id {}
variable name {}
variable paas_prometheus_exporter_endpoint {}
variable alertmanager_endpoint {}

variable additional_variable_map {
  type = map
  default = {
    do_nothing = "Nothing"
  }
}

variable alert_rules {
  default = ""
}

variable memory {
  default = 1024
}

variable instances {
  default = 1
}

variable disk_quota {
  default = 1024
}

variable config_file {
  default = ""
}

locals {
  template_variable_map = {
    paas_prometheus_exporter_endpoint = var.paas_prometheus_exporter_endpoint
    alertmanager_endpoint             = var.alertmanager_endpoint
    name                              = var.name
  }
}


