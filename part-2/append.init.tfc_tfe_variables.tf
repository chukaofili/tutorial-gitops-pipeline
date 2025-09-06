# Append the contents of this file to part-1/terraform/init/tfc_tfe_variables.tf.

resource "tfe_variable" "terraform_cloud_github_organisation_name" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "github_organisation"
  value        = var.github_organisation
  category     = "terraform"
  description  = "GitHub organization"
}
