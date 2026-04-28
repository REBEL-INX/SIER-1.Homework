# Defines provider for hashicorp/local and hashicorp/google
# Google provider is used to create resources in GCP. Local provider creates files on local machine.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "seir01"
  region = "us-central1"
}
# Google provider confirged for my project. Depoloys infrasctucre in us-central1 (Iowa) region.