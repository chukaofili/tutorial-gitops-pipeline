terraform {
  cloud {
    # The organization and workspace name will be set during terraform init
    # These values should match what you configured in the init scripts
    organization = var.terraform_cloud_organization_name

    workspaces {
      name = var.terraform_cloud_workspace_name
    }
  }
}
