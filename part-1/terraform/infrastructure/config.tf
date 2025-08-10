terraform {
  cloud {
    organization = var.terraform_cloud_organization_name

    workspaces {
      name = var.terraform_cloud_workspace_name
    }
  }
}
