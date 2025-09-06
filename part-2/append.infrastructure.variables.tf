variable "flux_cluster_name" {
  description = "Flux cluster config name"
  type        = string
  default     = "primary-cluster"
}

variable "github_repository_branch" {
  description = "Flux git repository branch"
  type        = string
  default     = "main"
}
