resource cloudfoundry_route prometheus {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.space_id
  hostname = "prometheus-${var.name}"
}

resource cloudfoundry_app prometheus {
  name             = "prometheus-${var.name}"
  space            = var.space_id
  path             = data.archive_file.config.output_path
  source_code_hash = data.archive_file.config.output_base64sha256
  buildpack        = "https://github.com/alphagov/prometheus-buildpack.git"
  routes {
    route = cloudfoundry_route.prometheus.id
  }
}

