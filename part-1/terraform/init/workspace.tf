data "tfe_organization" "org" {
  name = var.terraform_cloud_organization_name
}

/*
  Since we're using github as the VCS provider, we need to get the github app installation id.
  this will be used to setup the vcs repo for the workspace. You've havn't set this up, you'll need to do that before

  1. Open the Terraform Cloud UI and navigate to the organization settings.
  2. Under "VCS Providers" click "Connect VCS" and select "GitHub App".
  3. Install the app into your GitHub org/repo(s).
  4. This will produce an installation ID that Terraform can reference.

  Note: You could also use a different vcs provider like gitlab, bitbucket, etc. but for this tutorial we'll be using github.
*/
data "tfe_github_app_installation" "gha_installation" {
  name = var.github_organisation
}

/*
  This will setup the main project that will be used to house all workspaces under one project which could be your company name, or product name if you have multiple products eg: 'notestack'
*/
resource "tfe_project" "main_project" {
  organization = data.tfe_organization.org.name
  name         = var.terraform_cloud_project_name
}

/*
  This will setup the main workspace that will be used to house all infrastructure under one workspace which could be your company name, or product name if you have multiple products eg: 'notestack'.
  Things to note: this will also setup auto apply and auto deploy on push to the github repository.
*/
resource "tfe_workspace" "main_workspace" {
  organization = data.tfe_organization.org.name
  project_id   = tfe_project.main_project.id
  name         = var.terraform_cloud_workspace_name

  # This sets the trigger patterns for the workspace, it will trigger and auto apply when there is a change in the infrastructure folder for the github repository.
  trigger_patterns = ["${var.github_working_directory}/**/*"]

  # This sets the current working deirectory that will be used to run the terraform commands from the github repository.
  working_directory = var.github_working_directory

  # This sets the auto apply to true, this will auto apply the changes to the infrastructure when there is a change in the infrastructure folder.
  auto_apply             = true
  auto_apply_run_trigger = true

  # This sets the terraform version to the latest version, also try to kep your cli version uptodate and in sync with the terraform version.
  terraform_version = "latest"

  # This sets the vcs repo to the github repository that will be used to house the infrastructure code.
  vcs_repo {
    github_app_installation_id = data.tfe_github_app_installation.gha_installation.id
    identifier                 = "${var.github_organisation}/${var.github_repository}"
    ingress_submodules         = false
  }
}
