variable "github_organisation" {
  description = "Github organisation name, use this to specify the github organisation name to use for terraform cloud this can be either github individual or a team org account"
  type        = string
}

variable "flux_cluster_name" {
  description = "FluxCD cluster name"
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
