terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.47.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }

  required_version = "~> 1.12"
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
}
