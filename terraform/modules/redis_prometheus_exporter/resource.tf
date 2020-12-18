resource cloudfoundry_service_key redis-key {
  name             = "redis-key"
  service_instance = var.redis_service_instance_id
}

locals {
  url = "rediss://${cloudfoundry_service_key.redis-key.credentials.host}:${cloudfoundry_service_key.redis-key.credentials.port}"
}

resource cloudfoundry_app redis-exporter {
  name         = "redis-exporter-${var.monitoring_instance_name}"
  space        = var.monitoring_space_id
  docker_image = "oliver006/redis_exporter:latest"

  routes {
    route = cloudfoundry_route.redis_exporter.id
  }

  environment = {
    REDIS_ADDR     = local.url
    REDIS_PASSWORD = cloudfoundry_service_key.redis-key.credentials.password
  }
}

resource cloudfoundry_route redis_exporter {
  space    = var.monitoring_space_id
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = "redis-exporter-${var.monitoring_instance_name}"
}

