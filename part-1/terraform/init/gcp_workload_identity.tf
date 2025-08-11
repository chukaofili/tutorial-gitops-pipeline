resource "google_project_service" "gcp_apis" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])
  service            = each.value
  disable_on_destroy = false
}

/*
  This will create a Workload Identity Pool in Google Cloud that will be used to authenticate Terraform Cloud
  to manage Google Cloud resources. This is more secure than using service account keys.
*/
resource "google_iam_workload_identity_pool" "terraform_cloud_pool" {
  workload_identity_pool_id = var.workload_identity_pool_id
  display_name              = "Terraform Cloud Pool"
  description               = "Workload Identity Pool for Terraform Cloud"

  depends_on = [
    google_project_service.gcp_apis
  ]
}

/*
  This will create a Workload Identity Provider that will be used to authenticate Terraform Cloud
  workloads to Google Cloud using OIDC tokens from Terraform Cloud.
*/
resource "google_iam_workload_identity_pool_provider" "terraform_cloud_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.terraform_cloud_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.workload_identity_provider_id
  display_name                       = "Terraform Cloud Provider"
  description                        = "OIDC identity pool provider for Terraform Cloud"

  attribute_mapping = {
    "google.subject"                        = "assertion.sub"
    "attribute.terraform_organization_id"   = "assertion.terraform_organization_id"
    "attribute.terraform_organization_name" = "assertion.terraform_organization_name"
    "attribute.terraform_workspace_id"      = "assertion.terraform_workspace_id"
    "attribute.terraform_workspace_name"    = "assertion.terraform_workspace_name"
    "attribute.terraform_run_phase"         = "assertion.terraform_run_phase"
    "attribute.terraform_project_id"        = "assertion.terraform_project_id"
    "attribute.terraform_project_name"      = "assertion.terraform_project_name"
  }

  oidc {
    issuer_uri = "https://app.terraform.io"
  }

  # This condition here will make sure that the workload identity provider is only used by the terraform cloud workspace that is specified in the terraform.tfvars file.
  attribute_condition = "assertion.terraform_organization_name==\"${var.terraform_cloud_organization_name}\" && assertion.terraform_workspace_name==\"${var.terraform_cloud_workspace_name}\""
}

/*
  This will create a service account that Terraform Cloud will use to manage Google Cloud resources.
  This service account will be configured to use Workload Identity for authentication.
*/
resource "google_service_account" "terraform_cloud_sa" {
  account_id   = var.service_account_id
  display_name = "Terraform Cloud Service Account"
  description  = "Service account for Terraform Cloud to manage Google Cloud resources"

  depends_on = [
    google_project_service.gcp_apis
  ]
}

/*
  This will bind the service account to the Workload Identity Pool so that Terraform Cloud
  can impersonate the service account using OIDC tokens.
*/
resource "google_service_account_iam_binding" "terraform_cloud_workload_identity" {
  service_account_id = google_service_account.terraform_cloud_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.terraform_cloud_pool.name}/attribute.terraform_workspace_name/${var.terraform_cloud_workspace_name}"
  ]

  depends_on = [
    google_project_service.gcp_apis
  ]
}

/*
  This will grant the service account the necessary permissions to manage Google Cloud resources.
  You may need to adjust these roles based on what resources your infrastructure will create.
*/
resource "google_project_iam_member" "terraform_cloud_sa_permissions" {
  for_each = toset([
    "roles/artifactregistry.admin",
    "roles/cloudsql.admin",
    "roles/compute.admin",
    "roles/container.admin",
    "roles/dns.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/secretmanager.admin",
    "roles/storage.admin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/logging.admin"
  ])

  project = var.google_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.terraform_cloud_sa.email}"

  depends_on = [
    google_project_service.gcp_apis
  ]
}
