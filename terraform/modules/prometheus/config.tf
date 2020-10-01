locals {
  config_file = var.config_file == "" ? "${path.module}/templates/prometheus.yml.tmpl" : var.config_file
}

data archive_file config {
  type        = "zip"
  output_path = "${path.module}/files/prometheus.zip"

  source {
    content  = templatefile(local.config_file, merge(local.template_variable_map, var.additional_variable_map))
    filename = "prometheus.yml"
  }

  source {
    content  = var.alert_rules
    filename = "alert.rules"
  }
}
