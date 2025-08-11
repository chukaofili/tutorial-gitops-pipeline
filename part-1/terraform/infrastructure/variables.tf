variable "terraform_cloud_organization_name" {
  description = "Terraform cloud organisation name, this should already have been created from the init scripts"
  type        = string
}

variable "terraform_cloud_workspace_name" {
  description = "Terraform cloud workspace name, this should already have been created from the init scripts"
  type        = string
}

variable "google_project_id" {
  description = "Google Cloud project ID where resources will be created"
  type        = string
}

variable "google_region" {
  description = "Google Cloud region for resources"
  type        = string
  default     = "europe-west2"
}
