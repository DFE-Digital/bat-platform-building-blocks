output endpoint {
  value = cloudfoundry_route.prometheus.endpoint
}

output app_id {
  value = cloudfoundry_app.prometheus.id
}

output config {
  value = local.config_file
}
