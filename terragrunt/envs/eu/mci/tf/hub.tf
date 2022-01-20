resource "google_gke_hub_membership" "membership" {
  project = "${var.project_id}"
  membership_id = "${var.cluster_name}-${var.region}"
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${var.cluster_id}"
    }
  }
  description = "Membership"
  provider = google-beta
}

resource "google_gke_hub_feature" "feature" {
  name = "multiclusteringress"
  project = "${var.project_id}"
  location = "global"
  spec {
    multiclusteringress {
      config_membership = google_gke_hub_membership.membership.id
    }
  }
  provider = google-beta
}
