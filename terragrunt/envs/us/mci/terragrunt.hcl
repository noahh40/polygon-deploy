terraform {
  source = "./tf"
}

dependency "gke" {
  config_path = "../gke"

}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_id = "helix-new-polygon"
  region = "us-central1"
  cluster_id = dependency.gke.outputs.cluster_id
  cluster_name = dependency.gke.outputs.name
}
