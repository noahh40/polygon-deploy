terraform {
  source = "tfr:///terraform-google-modules/address/google?version=3.1.0"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    network_name = "vpc-network-name"
  }
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_id = "helix-dev-polygon-342021"
  network_name = dependency.vpc.outputs.network.network.id
  address_type = "EXTERNAL"
  global = true
  region = "europe-west4" // variable is delared in module, we must provide any value
  names = ["mci-address"]
}
