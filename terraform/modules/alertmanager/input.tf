variable monitoring_instance_name {}

variable monitoring_space_id {}

variable config { default = "" }

locals {
  config = var.config == "" ? file("${path.module}/config/alertmanager.yml") : var.config
}
