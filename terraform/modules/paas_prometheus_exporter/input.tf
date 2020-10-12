variable monitoring_org_name {}

variable monitoring_space_id {}

variable environment_variable_map {
  type = map
  default = {
    Nothing = ""
  }
}

locals {
  api_endpoint = "https://api.london.cloud.service.gov.uk"
}
