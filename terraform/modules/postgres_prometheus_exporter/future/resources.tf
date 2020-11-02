resource cloudfoundry_route redis_exporter {
  space    = var.monitoring_space_id
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = "redis-exporter-${var.name}"
}

resource cloudfoundry_app redis_exporter {
  name         = "redis-exporter-${var.name}"
  space        = var.monitoring_space_id
  docker_image = "oliver006/redis_exporter:latest"
  routes {
    route = cloudfoundry_route.redis_exporter.id
  }
  service_binding {
    service_instance = data.cloudfoundry_service_instance.redis.id
  }

}



