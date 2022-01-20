terraform {
  source = "tfr:///terraform-google-modules/service-accounts/google?version=4.0.3"
}

dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    network_name = "vpc-network-name"
  }
  skip_outputs = true
}

dependency "kms" {
  config_path = "../../kms"
  # mock_outputs = {
  #   network_name = "vpc-network-name"
  # }
}

locals {
  region = "us-central1"
  prefix = "polygon"
  project_id = "${get_env("project_id")}"
}

inputs = {
  project_id = local.project_id
  names = ["${local.prefix}-${local.region}-cluster-sa"]
  description = "Cluster SA"
  project_roles = [
    "${local.project_id}=>roles/storage.objectViewer",
    "${local.project_id}=>roles/artifactregistry.reader",
  ]
}
