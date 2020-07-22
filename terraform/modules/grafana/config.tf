locals {
    tmp_data    = var.datasource_directory == "" ? "${path.module}/datasources/"       : var.datasource_directory
    tmp_dash    = var.dashboard_directory  == "" ? "${path.module}/dashboards/"        : var.dashboard_directory
    tmp_plug    = var.plugins_file         == "" ? "${path.module}/config/plugins.txt" : var.plugins_file
    tmp_config  = var.configuration_file   == "" ? "${path.module}/config/grafana.ini" : var.configuration_file

    dashboards = fileset("${local.tmp_dash}", "*.json")
    datasources = fileset("${local.tmp_data}", "*.yml.tmpl")
    plugins     = fileset("${local.tmp_plug}", "*.zip")

}

data archive_file config {
  type        = "zip"
  output_path = "${path.module}/files/grafana.zip"

  source {
    content  = file( "${local.tmp_plug}" )
    filename = "plugins.txt"
  }

  source {
    content  = templatefile( "${local.tmp_config}" , var.additional_variable_map )
    filename = "grafana.ini"
  }

  source {
    content  = file("${path.module}/files/dashboard_provider.yml")
    filename = "dashboards/dashboard_provider.yml"
  }

  dynamic "source" {
    for_each = local.datasources
    content {
      content  = templatefile("${local.tmp_data}/${source.key}" , merge( local.template_variable_map , var.additional_variable_map ))
      filename = replace( "datasources/${source.key}" , ".tmpl" , "" )
    }
  }
  dynamic "source" {
    for_each = local.dashboards
    content {
      content  = file("${local.tmp_dash}/${source.key}")
      filename = "dashboards/${source.key}"
    }
  }

}

