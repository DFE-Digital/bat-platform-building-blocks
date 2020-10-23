variable monitoring_org_name {}

variable monitoring_space_id {}

variable config { default = "" }

locals {
  tmp_config   = var.config == "" ? file("${path.module}/config/alertmanger.yml") : var.config
}
