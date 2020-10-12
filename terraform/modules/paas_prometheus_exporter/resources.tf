resource cloudfoundry_route paas_prometheus_exporter {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.monitoring_space_id
  hostname = "app-prometheus-exporter-${var.monitoring_org_name}"
}

resource cloudfoundry_app paas_prometheus_exporter {
  name         = "paas-prometheus-exporter-${var.monitoring_org_name}"
  space        = var.monitoring_space_id
  docker_image = "governmentpaas/paas-prometheus-exporter:ae92e64f45264d450626cb33802b3649b68562d4"
  command      = "paas-prometheus-exporter"
  routes {
    route = cloudfoundry_route.paas_prometheus_exporter.id
  }
  environment = var.environment_variable_map
}
