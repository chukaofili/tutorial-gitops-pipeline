resource "tfe_variable" "terraform_cloud_workspace_name" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "github_organisation"
  value        = var.github_organisation
  category     = "terraform"
  description  = "GitHub organization"
}

resource "tfe_variable" "terraform_cloud_workspace_name" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "github_repository"
  value        = var.github_repository
  category     = "terraform"
  description  = "GitHub repository"
}
