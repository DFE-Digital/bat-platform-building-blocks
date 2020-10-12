resource cloudfoundry_route alertmanager {
  domain   = data.cloudfoundry_domain.cloudapps.id
  space    = var.monitoring_space_id
  hostname = "alertmanager-${var.monitoring_org_name}"
}

resource cloudfoundry_app alertmanager {
  name         = "alertmanager-${var.monitoring_org_name}"
  space        = var.monitoring_space_id
  docker_image = "prom/alertmanager"
  command      = "echo \"$${CONFIG}\" > cfg.yml ; alertmanager --web.listen-address=:$${PORT} --config.file=cfg.yml"
  routes {
    route = cloudfoundry_route.alertmanager.id
  }
  environment = {
    CONFIG = var.config
  }
}
