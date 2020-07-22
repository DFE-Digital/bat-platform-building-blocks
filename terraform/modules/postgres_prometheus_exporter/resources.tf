resource "cloudfoundry_app" "postgres-exporter" {
  name             = "postgres-exporter-${var.name}"
  space            =  var.install_space_id
  docker_image     =  "wrouesnel/postgres_exporter"
  ports            = [9187]
  routes {
    route = cloudfoundry_route.postgres-exporter.id
  }
  service_binding  {
        service_instance = data.cloudfoundry_service_instance.postgres.id
  }
  environment = { 
     PG_EXPORTER_WEB_LISTEN_ADDRESS = "0.0.0.0:9187"
  }
}

output postgres_data {
   value = cloudfoundry_app.postgres-exporter 
}
output endpoint {
  value = cloudfoundry_route.postgres-exporter.endpoint
}

resource cloudfoundry_route postgres-exporter {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.install_space_id
  hostname = "postgres-exporter-${var.name}"
}

