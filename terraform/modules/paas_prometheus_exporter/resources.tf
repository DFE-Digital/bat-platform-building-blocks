resource cloudfoundry_route paas_prometheus_exporter {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.monitoring_space_id
  hostname = "paas-prometheus-exporter-${var.monitoring_instance_name}"
}

resource cloudfoundry_app paas_prometheus_exporter {
  name         = "paas-prometheus-exporter-${var.monitoring_instance_name}"
  space        = var.monitoring_space_id
  docker_image = "governmentpaas/paas-prometheus-exporter:${local.docker_image_tag}"
  command      = "paas-prometheus-exporter"
  routes {
    route = cloudfoundry_route.paas_prometheus_exporter.id
  }
  environment = local.environment_variable_map
}
