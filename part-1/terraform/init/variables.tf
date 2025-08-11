variable "terraform_cloud_organization_name" {
  description = "Terraform cloud organisation name, Make sure terraform organisation exists in your terraform cloud account, if you are not sure, you can create one using the terraform cloud UI here: https://app.terraform.io"
  type        = string
}

variable "terraform_cloud_project_name" {
  description = "Terraform cloud project name, use this to house all groups of workspaces under one project which could be your company name, or product name if you have multiple products eg: 'notestack'"
  type        = string
}

variable "terraform_cloud_workspace_name" {
  description = "Terraform cloud workspace name, use this to logically group your infrastructure eg: 'development', 'staging', 'production'"
  type        = string
}

variable "github_organisation" {
  description = "Github organisation name, use this to specify the github organisation name to use for terraform cloud this can be either github individual or a team org account"
  type        = string
}

variable "github_repository" {
  description = "Github repository name, use this to specify the github repository name to use for terraform cloud"
  type        = string
}

variable "github_working_directory" {
  description = "Github working directory, use this to specify the github working directory to use for terraform cloud"
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

variable "workload_identity_pool_id" {
  description = "ID for the Workload Identity Pool"
  type        = string
  default     = "terraform-cloud-pool"
}

variable "workload_identity_provider_id" {
  description = "ID for the Workload Identity Provider"
  type        = string
  default     = "terraform-cloud-provider"
}

variable "service_account_id" {
  description = "ID for the service account that Terraform Cloud will use"
  type        = string
  default     = "terraform-cloud-sa"
}
