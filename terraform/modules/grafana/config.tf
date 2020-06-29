data archive_file config {
  type        = "zip"
  output_path = "${path.module}/files/grafana.zip"

  source {
    content  = templatefile("${path.module}/templates/prometheus.yml.tmpl", local.template_variable_map)
    filename = "datasources/prometheus.yml"
  }

  source {
    content  = file("${path.module}/files/dashboard_provider.yml")
    filename = "dashboards/dashboard_provider.yml"
  }

  dynamic "source" {
    for_each = var.json_dashboards
    content {
      content  = source.value
      filename = "dashboards/dashboard_${source.key}.json"
    }
  }
}
