
resource "cloudfoundry_app" "redis-exporter" {
  name         = "redis-exporter-${var.name}"
  space        = var.monitor_space_id
  docker_image = "oliver006/redis_exporter:latest"
  ports        = [9187]

  routes {
    route = cloudfoundry_route.redis_exporter.id
  }
  service_binding {
    service_instance = data.cloudfoundry_service_instance.redis.id
  }
  environment = {
    REDIS_EXPORTER_WEB_LISTEN_ADDRESS = "0.0.0.0:9187"
  }
}

output redis_data {
  value = cloudfoundry_app.redis-exporter
}

resource cloudfoundry_route redis_exporter {
  space    = var.monitor_space_id
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = "redis-exporter-${var.name}"
}

