data archive_file config {
  type        = "zip"
  output_path = "${path.module}/files/prometheus.zip"

  source {
    content  = local.config_file
    filename = "prometheus.yml"
  }

  source {
    content  = var.alert_rules
    filename = "alert.rules"
  }
}
