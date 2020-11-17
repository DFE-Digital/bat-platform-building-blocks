output service_instance_id {
  value = cloudfoundry_service_instance.influxdb.id
}

output credentials {
  value = cloudfoundry_service_key.influxdb-key.credentials
}
