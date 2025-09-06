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
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "production"
}

# GKE Variables
variable "gke_cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "primary-cluster"
}

variable "gke_node_count" {
  description = "Number of nodes per zone in the node pool. For regional clusters this is multiplied by the number of zones (default 3). To control total node count, either reduce this value or switch to a zonal cluster."
  type        = number
  default     = 1
}

variable "gke_node_disk_size" {
  description = "Disk size in GB for GKE nodes"
  type        = number
  default     = 20
}

variable "gke_node_disk_type" {
  description = "Disk type for GKE nodes"
  type        = string
  default     = "pd-balanced"
}

variable "gke_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "n2-standard-4"
}

# Cloud SQL Variables
variable "sql_instance_name" {
  description = "Name of the Cloud SQL instance"
  type        = string
  default     = "postgres-instance"
}

variable "sql_tier" {
  description = "Machine type for Cloud SQL instance"
  type        = string
  default     = "db-custom-1-3840"
}

variable "sql_disk_size" {
  description = "Disk size in GB for Cloud SQL instance"
  type        = number
  default     = 20
}

variable "sql_database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "notestack_db"
}

variable "sql_user_name" {
  description = "Username for the database user"
  type        = string
  default     = "app_user"
}

variable "github_organisation" {
  description = "Github organisation name, use this to specify the github organisation name to use for terraform cloud this can be either github individual or a team org account"
  type        = string
}

variable "flux_cluster_name" {
  description = "FluxCD cluster config name"
  type        = string
  default     = "primary-cluster"
}

variable "flux_repository" {
  description = "FluxCD Github repository name, use this to specify the github repository used for fluxcd to manage the cluster state"
  type        = string
  default     = "fluxcd"
}

variable "flux_repository_branch" {
  description = "FluxCD git repository branch to use"
  type        = string
  default     = "main"
}
