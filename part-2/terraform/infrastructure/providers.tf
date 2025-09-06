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
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.6.4"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
  }

  required_version = "~> 1.12"
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
}

provider "github" {
  owner = var.github_organization
}
