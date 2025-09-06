terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.68.2"
    }
    google = {
      source  = "hashicorp/google"
      version = "6.47.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
}

provider "github" {
  token = var.github_token
  owner = var.github_organization
}

/*
  This data source is used to get the Google Cloud project number which is required
  for setting up Workload Identity authentication.
*/

data "google_project" "project" {
  project_id = var.google_project_id
}
