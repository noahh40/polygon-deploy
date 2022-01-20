terraform {
  source = "tfr:///terraform-google-modules/project-factory/google//modules/project_services?version=11.2.3"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_id = "helix-new-polygon"
  disable_services_on_destroy = false
  activate_apis = [
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "servicenetworking.googleapis.com",
    "stackdriver.googleapis.com",
    "cloudkms.googleapis.com",
    "artifactregistry.googleapis.com",
    "multiclusteringress.googleapis.com",
    "multiclusterservicediscovery.googleapis.com",
    "gkehub.googleapis.com",
    "gkeconnect.googleapis.com",
  ]
}
