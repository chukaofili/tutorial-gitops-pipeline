terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe"
    }
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
}

/*
  This data source is used to get the Google Cloud project number which is required
  for setting up Workload Identity authentication.
*/

data "google_project" "project" {
  project_id = var.google_project_id
}
