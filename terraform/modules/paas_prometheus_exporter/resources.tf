resource cloudfoundry_route paas_prometheus_exporter {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.space_id
  hostname = "paas-prometheus-exporter-${var.name}"
}

resource cloudfoundry_app paas_prometheus_exporter {
  name         = "paas-prometheus-exporter-${var.name}"
  space        = var.space_id
  docker_image = "governmentpaas/paas-prometheus-exporter:ae92e64f45264d450626cb33802b3649b68562d4"
  command      = "paas-prometheus-exporter"
  routes {
    route = cloudfoundry_route.paas_prometheus_exporter.id
  }
  environment = {
    API_ENDPOINT = local.api_endpoint
    USERNAME     = var.username
    PASSWORD     = var.password
  }
}
