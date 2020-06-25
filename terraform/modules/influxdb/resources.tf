resource cloudfoundry_service_instance influxdb {
  name         = "influxdb-${var.name}"
  space        = var.space_id
  service_plan = data.cloudfoundry_service.influxdb.service_plans["tiny-1_x"]
}
