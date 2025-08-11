/*
  These are the Terraform Cloud variables that will be automatically set in the workspace
  to enable Google Cloud authentication using Workload Identity. These variables tell
  Terraform Cloud how to authenticate with Google Cloud using OIDC tokens.
*/
resource "tfe_variable" "tfc_gcp_provider_auth" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "TFC_GCP_PROVIDER_AUTH"
  value        = true
  category     = "env"
  description  = "Enable Google Cloud provider authentication via Workload Identity"
}

resource "tfe_variable" "tfc_gcp_project_number" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "TFC_GCP_PROJECT_NUMBER"
  value        = data.google_project.project.number
  category     = "env"
  description  = "Google Cloud project number for Workload Identity"
}

resource "tfe_variable" "tfc_gcp_workload_identity_pool_id" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "TFC_GCP_WORKLOAD_POOL_ID"
  value        = google_iam_workload_identity_pool.terraform_cloud_pool.workload_identity_pool_id
  category     = "env"
  description  = "Workload Identity Pool ID for authentication"
}

resource "tfe_variable" "tfc_gcp_workload_identity_provider_id" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "TFC_GCP_WORKLOAD_PROVIDER_ID"
  value        = google_iam_workload_identity_pool_provider.terraform_cloud_provider.workload_identity_pool_provider_id
  category     = "env"
  description  = "Workload Identity Provider ID for authentication"
}

resource "tfe_variable" "tfc_gcp_service_account_email" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value        = google_service_account.terraform_cloud_sa.email
  category     = "env"
  description  = "Service account email for Workload Identity impersonation"
}

resource "tfe_variable" "github_token" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "GITHUB_TOKEN"
  value        = var.github_token
  category     = "env"
  sensitive    = true
  description  = "GitHub personal access token with admin permissions"
}

/*
  Additional Terraform variables that will be available in the infrastructure workspace
*/
resource "tfe_variable" "google_project_id" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "google_project_id"
  value        = var.google_project_id
  category     = "terraform"
  description  = "Google Cloud project ID"
}

resource "tfe_variable" "google_region" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "google_region"
  value        = var.google_region
  category     = "terraform"
  description  = "Google Cloud region"
}

resource "tfe_variable" "terraform_cloud_organization_name" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "terraform_cloud_organization_name"
  value        = data.tfe_organization.org.name
  category     = "terraform"
  description  = "Terraform Cloud organization"
}

resource "tfe_variable" "terraform_cloud_workspace_name" {
  workspace_id = tfe_workspace.main_workspace.id
  key          = "terraform_cloud_workspace_name"
  value        = tfe_workspace.main_workspace.name
  category     = "terraform"
  description  = "Terraform Cloud workspace"
}
