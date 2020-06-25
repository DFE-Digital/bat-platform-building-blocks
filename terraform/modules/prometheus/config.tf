data archive_file config {
  type        = "zip"
  output_path = "${path.module}/files/prometheus.zip"

  source {
    content  = templatefile("${path.module}/templates/prometheus.yml.tmpl", local.template_variable_map)
    filename = "prometheus.yml"
  }

  source {
    content  = var.alert_rules
    filename = "alert.rules"
  }
}
