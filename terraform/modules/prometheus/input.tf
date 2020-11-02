variable monitoring_space_id {}

variable monitoring_instance_name {}

variable paas_prometheus_exporter_endpoint {}

variable alertmanager_endpoint { default = "" }

variable memory { default = 1024 }

variable disk_quota { default = 1024 }

variable influxdb_service_instance_id {}

variable additional_variable_map {
  type = map
  default = {
    do_nothing = "Nothing"
  }
}

variable alert_rules {
  default = ""
}

variable config_file {
  default = ""
}

locals {
  template_variable_map = {
    paas_prometheus_exporter_endpoint = var.paas_prometheus_exporter_endpoint
    alertmanager_endpoint             = var.alertmanager_endpoint
    paas_prometheus_exporter_name     = "paas-prometheus-exporter-${var.monitoring_instance_name}"
    include_alerting                  = var.alert_rules == "" ? false : true
  }
}
