terraform {
  source = "./tf"
}

dependency "gke" {
  config_path = "../gke"
  # mock_outputs = {
  #   network_name = "vpc-network-name"
  # }
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_id = "helix-new-polygon"
  region = "europe-west4"
  cluster_id = dependency.gke.outputs.cluster_id
  cluster_name = dependency.gke.outputs.name
}
