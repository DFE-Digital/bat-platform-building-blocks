output endpoint {
  value = cloudfoundry_route.prometheus.endpoint
}

output id {
  value = cloudfoundry_route.prometheus.id
}


output config {
   value = local.config_file 
}
