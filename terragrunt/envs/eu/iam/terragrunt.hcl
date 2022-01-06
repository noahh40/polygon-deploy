terraform {
  source = "tfr:///terraform-google-modules/service-accounts/google?version=4.0.3"
}

dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    network_name = "vpc-network-name"
  }
}

dependency "kms" {
  config_path = "../../kms"
  # mock_outputs = {
  #   network_name = "vpc-network-name"
  # }
}

locals {
  region = "eu-west4"
  prefix = "polygon"
  project_id = "helix-dev-polygon"
}

inputs = {
  project_id = local.project_id
  names = ["${local.prefix}-${local.region}-cluster1-sa"]
  description = "Cluster SA"
  project_roles = [
    "${local.project_id}=>roles/storage.objectViewer",
    "${local.project_id}=>roles/artifactregistry.reader",
  ]
}
