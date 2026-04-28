# Our VPC network configuration
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network

resource "google_compute_network" "week7vpc_network" {
  name                    = "week7vpc-network"
  auto_create_subnetworks = false # Set to true by deafult, we want to create our own subnets, so set to false.
  mtu                     = 1460
}

# Subnet Config
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork

resource "google_compute_subnetwork" "week7vpc_subnet" {
  name          = "week7vpc-subnetwork"
  ip_cidr_range = "10.28.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.week7vpc_network.id
}
