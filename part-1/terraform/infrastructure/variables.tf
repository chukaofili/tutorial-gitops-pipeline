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
  description = "Number of nodes in the GKE node pool"
  type        = number
  default     = 4
}

variable "gke_node_disk_size" {
  description = "Disk size in GB for GKE nodes"
  type        = number
  default     = 50
}

variable "gke_node_disk_type" {
  description = "Disk type for GKE nodes"
  type        = string
  default     = "pd-balanced"
}

variable "gke_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-small"
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
