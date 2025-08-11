terraform {
  cloud {
    # The organization and workspace name will be set during terraform init
    # These values should match what you configured in the init scripts
    organization = "your-terraform-cloud-org"

    workspaces {
      name = "your-workspace-name"
    }
  }
}
