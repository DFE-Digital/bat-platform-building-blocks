resource cloudfoundry_service_instance influxdb {
  name         = "influxdb-${var.monitoring_instance_name}"
  space        = var.monitoring_space_id
  service_plan = data.cloudfoundry_service.influxdb.service_plans["tiny-1_x"]
}

resource cloudfoundry_service_key influxdb-key {
  name             = "prometheus-key"
  service_instance = cloudfoundry_service_instance.influxdb.id
}
