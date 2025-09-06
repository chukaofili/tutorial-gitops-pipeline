# Append the contents of this file to part-1/terraform/init/tfc_tfe_variables.tf.

resource "tfe_variable" "terraform_cloud_github_organization_name" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "github_organization"
  value        = var.github_organization
  category     = "terraform"
  description  = "GitHub organization"
}

resource "tfe_variable" "terraform_cloud_github_token" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "github_token"
  value        = var.github_token
  category     = "terraform"
  sensitive    = true
  description  = "GitHub personal access token with admin permissions"
}
