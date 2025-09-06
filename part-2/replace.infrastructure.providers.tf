# Replace the contents of this file to part-1/terraform/infrastructure/providers.tf.

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    random = {
      source = "hashicorp/random"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    github = {
      source = "integrations/github"
    }
    flux = {
      source = "fluxcd/flux"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }

  required_version = "~> 1.12"
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
}

provider "github" {
  owner = var.github_organisation
}
