variable monitoring_space_id {}

variable monitoring_instance_name {}

variable paas_prometheus_exporter_endpoint {}

variable redis_prometheus_exporter_endpoint { default = "" }

variable alertmanager_endpoint { default = "" }

variable memory { default = 1024 }

variable disk_quota { default = 1024 }

variable influxdb_service_instance_id {}

variable alert_rules { default = "" }

variable extra_scrape_config { default = "" }

locals {
  template_variable_map = {
    paas_prometheus_exporter_endpoint  = var.paas_prometheus_exporter_endpoint
    redis_prometheus_exporter_endpoint = var.redis_prometheus_exporter_endpoint
    alertmanager_endpoint              = var.alertmanager_endpoint
    paas_prometheus_exporter_name      = "paas-prometheus-exporter-${var.monitoring_instance_name}"
    include_alerting                   = var.alert_rules == "" ? false : true
    include_redis_exporter             = var.redis_prometheus_exporter_endpoint == "" ? false : true
    include_scrapes                    = var.extra_scrape_config == "" ? false : true
    scrapes                            = var.extra_scrape_config
  }

  config_file = templatefile("${path.module}/templates/prometheus.yml.tmpl", local.template_variable_map)
}
