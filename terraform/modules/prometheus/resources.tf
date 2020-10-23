resource cloudfoundry_route prometheus {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.monitoring_space_id
  hostname = "prometheus-${var.monitoring_org_name}"
}

resource cloudfoundry_app prometheus {
  name             = "prometheus-${var.monitoring_org_name}"
  space            = var.monitoring_space_id
  path             = data.archive_file.config.output_path
  memory           = var.memory
  disk_quota       = var.disk_quota
  source_code_hash = data.archive_file.config.output_base64sha256
  buildpack        = "https://github.com/alphagov/prometheus-buildpack.git"
  service_binding {
    service_instance = var.influxdb_service_instance_id
  }
  routes {
    route = cloudfoundry_route.prometheus.id
  }
}
