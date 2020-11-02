variable monitoring_instance_name {}
variable monitoring_space_id {}

variable paas_username {}
variable paas_password {}

locals {
  docker_image_tag = "ae92e64f45264d450626cb33802b3649b68562d4"
  paas_api_url     = "https://api.london.cloud.service.gov.uk"
  environment_variable_map = {
    API_ENDPOINT = local.paas_api_url
    USERNAME     = var.paas_username
    PASSWORD     = var.paas_password
  }
}
