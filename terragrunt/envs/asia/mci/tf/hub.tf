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
