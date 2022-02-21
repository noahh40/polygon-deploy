terraform {
  // source = "git@github.com:terraform-google-modules/terraform-google-network.git/v4.0.0/modules/subnets"
  source = "tfr:///terraform-google-modules/network/google?version=4.0.0"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  project_id = "helix-dev-polygon-342021"
  network_name = "polygon-dev-vpc-2"

  subnets = [
    {
      subnet_name           = "polygon-asia-east1-subnet"
      subnet_ip             = "10.2.0.0/20"
      subnet_private_access = "true"
      subnet_region         = "asia-east1"
    },
    {
      subnet_name           = "polygon-us-central1-subnet"
      subnet_ip             = "10.2.16.0/20"
      subnet_private_access = "true"
      subnet_region         = "us-central1"
    },
    {
      subnet_name           = "polygon-europe-west4-subnet"
      subnet_ip             = "10.2.32.0/20"
      subnet_private_access = "true"
      subnet_region         = "europe-west4"
    }
  ]

  secondary_ranges = {
    polygon-asia-east1-subnet = [
      {
        range_name    = "kubernetes-pods-range"
        ip_cidr_range = "10.64.0.0/18"
      },
      {
        range_name    = "kubernetes-services-range"
        ip_cidr_range = "10.64.64.0/18"
      }
    ]
    polygon-us-central1-subnet = [
      {
        range_name    = "kubernetes-pods-range"
        ip_cidr_range = "10.64.128.0/18"
      },
      {
        range_name    = "kubernetes-services-range"
        ip_cidr_range = "10.64.192.0/18"
      }
    ]
    polygon-europe-west4-subnet = [
      {
        range_name    = "kubernetes-pods-range"
        ip_cidr_range = "100.65.0.0/18"
      },
      {
        range_name    = "kubernetes-services-range"
        ip_cidr_range = "100.65.64.0/18"
      }
    ]
  }

  routes = [
    {
      name              = "polygon-egress-internet-vpc-1"
      description       = "Default route through IGW to access Internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }
  ]
}
