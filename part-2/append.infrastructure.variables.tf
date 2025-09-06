variable "github_organisation" {
  description = "Github organisation name, use this to specify the github organisation name to use for terraform cloud this can be either github individual or a team org account"
  type        = string
}

variable "github_repository" {
  description = "Github repository name, use this to specify the github repository name to use for terraform cloud"
  type        = string
}

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
