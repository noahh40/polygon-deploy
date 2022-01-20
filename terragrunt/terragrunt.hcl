remote_state {
  backend = "gcs"
  config = {
    # bucket     = "polygon-terraform-state"
    bucket = "${get_env("project_id", "my-terraform-bucket")}-terraform-state"
    # project    = "helix-new-polygon"
    prefix     = "${path_relative_to_include()}"
    project    = get_env("project_id", "my-terraform-bucket")
    location      = "EU"
  }
}
generate "state-backend.tf" {
  path      = "state-backend.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "gcs" {}
}
EOF
}