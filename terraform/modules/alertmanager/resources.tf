resource cloudfoundry_route alertmanager {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.space_id
  hostname = "alertmanager-${var.name}"
}

resource cloudfoundry_app alertmanager {
  name         = "alertmanager-${var.name}"
  space        = var.space_id
  docker_image = "prom/alertmanager"
  command      = "echo \"$${CONFIG}\" > cfg.yml ; alertmanager --web.listen-address=:$${PORT} --config.file=cfg.yml"
  routes {
    route = cloudfoundry_route.alertmanager.id
  }
  environment = {
    CONFIG = var.config
  }
}
