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

inputs = {
  region = "eu-west4"
  prefix = "polygon"
  project_id = "helix-new-polygon"
  # names = ["${prefix}-${region}-cluster-sa"]
  names = ["polygon-eu-west4-cluster-sa"]
  description = "Cluster SA"
  project_roles = [
    "dependency.vpc.outputs.project_id=>roles/storage.objectViewer"
    # "${project_id}=>roles/storage.objectViewer",
    # "${project_id}=>roles/artifactregistry.reader",
  ]
}
