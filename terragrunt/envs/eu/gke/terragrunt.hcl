terraform {
  source = "tfr:///terraform-google-modules/kubernetes-engine/google?version=17.1.0"
}

include {
  path = find_in_parent_folders()
}

dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    network_name = "vpc-network-name"
  }
}

dependency "iam" {
  config_path = "../iam"
  mock_outputs = {
    sa_email = "sa@example.com"
  }
}

dependency "glb" {
  config_path = "../../glb"
  mock_outputs = {
    sa_email = "sa@example.com"
  }
}

locals {
  region = "europe-west4"
  prefix = "polygon"
  project_id = "helix-new-polygon"
  vpc_subnetwork = "polygon-europe-west4-subnet"
  # kubernetes_version = "1.21.4-gke.2300"
  machine_type = "e2-standard-8"
  node_locations = "europe-west4-a"
}

inputs = {
  project_id = "${local.project_id}"
  name = "${local.prefix}-${local.region}-cluster"
  regional = true
  region = "${local.region}"
  zones = ["${local.region}-a", "${local.region}-b", "${local.region}-c"]
  network = dependency.vpc.outputs.network_name
  create_service_account = true
  master_authorized_networks = []
  subnetwork = "${local.vpc_subnetwork}"
  ip_range_pods = "kubernetes-pods-range"
  ip_range_services = "kubernetes-services-range"
  # kubernetes_version = "${local.kubernetes_version}"
  http_load_balancing = true
  horizontal_pod_autoscaling = true
  network_policy = false
  node_pools = [
    {
      name = "polygon-node-pool"
      machine_type = "${local.machine_type}"
      node_locations = "${local.node_locations}"
      min_count = 1
      max_count = 3
      disk_size_gb = 100
      disk_type = "pd-standard"
      image_tyyespe = "COS"
      auto_repair = true
      auto_upgrade = false
      service_account = dependency.iam.outputs.service_account.email
      preemptible = false
    }
  ]

  node_pools_oauth_scopes = {
      all = []
      polygon-node-pool = [
        "https://www.googleapis.com/auth/cloud-platform",
      ]
    }

  node_pools_labels = {
        all = {}
        polygon-node-pool = {
          polygon-node-pool = true
        }
      }

  node_pools_taints = {
      all = []
    }

  node_pools_tags = {
      all = [],
      polygon-node-pool = [
        "polygon-node-pool",
        ]
  }

}
