variable monitoring_instance_name {}

variable monitoring_space_id {}

variable config { default = "" }

variable slack_url { default = "" }
variable slack_channel { default = "" }

locals {
  map_variables = {
    slack_url     = var.slack_url
    slack_channel = var.slack_channel
  }
}

locals {
  config         = var.config == "" ? templatefile("${path.module}/config/alertmanager.yml", local.map_variables) : var.config
  slack_template = file("${path.module}/config/slack.tmpl")
}
