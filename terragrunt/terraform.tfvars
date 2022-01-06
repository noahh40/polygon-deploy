terragrunt = {
  remote_state {
    backend = "gcs"
    config {
      bucket = "polygon-terraform-state-files-test"
      region = "polygon"
      key    = format("%s/terraform.tfstate", path_relative_to_include())
    }
  }
}