resource cloudfoundry_route grafana {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.space_id
  hostname = "grafana-${var.name}"
}


resource cloudfoundry_app grafana {
  name             = "grafana-${var.name}"
  space            = var.space_id
  path             = data.archive_file.config.output_path
  source_code_hash = data.archive_file.config.output_base64sha256
  buildpack        = "https://github.com/SpringerPE/cf-grafana-buildpack"
  routes {
    route = cloudfoundry_route.grafana.id
  }
  environment = {
    ADMIN_PASS = var.admin_password
  }
}
