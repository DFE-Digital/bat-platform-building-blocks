variable space_id {}
variable paas_exporter_username {}
variable paas_exporter_password {}
variable name {}
variable alertmanager_config {}
variable grafana_admin_password {}
variable grafana_json_dashboards {
  type    = list
  default = []
}
variable alert_rules {
  default = ""
}
