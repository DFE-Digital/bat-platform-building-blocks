data cloudfoundry_service_instance postgres {
    name_or_id  = var.postgres-service-name
    space = var.monitor_space_id
}
