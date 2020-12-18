variable monitoring_instance_name {}
variable monitoring_org_name {}
variable monitoring_space_name {}

variable paas_exporter_username {}
variable paas_exporter_password {}

variable alertmanager_config { default = "" }
variable alertmanager_slack_url { default = "" }
variable alertmanager_slack_channel { default = "" }
variable alert_rules { default = "" }

variable grafana_google_client_id { default = "" }
variable grafana_google_client_secret { default = "" }
variable grafana_admin_password {}
variable grafana_json_dashboards { default = [] }
variable grafana_extra_datasources { default = [] }

variable prometheus_memory { default = null }
variable prometheus_disk_quota { default = null }

variable enabled_modules {
  type = list
  default = [
    "paas_prometheus_exporter",
    "prometheus",
    "grafana",
    "alertmanager",
    "influxdb"
  ]
}
