terraform {
  source = "tfr:///terraform-google-modules/kms/google?version=2.0.1"
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
  project_id = "helix-new-polygon"
  network_name = "polygon-vpc"

  location = "global"
  keyring = "polygon"
  keys    = ["polygon"]

}