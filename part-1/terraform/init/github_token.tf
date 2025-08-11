/*
  Creates a GitHub personal access token with repo admin permissions for use in Terraform Cloud workspace.
  This token is separate from the CLI token and will be used as GITHUB_TOKEN env var.
*/

resource "github_repository_personal_access_token" "github_token" {
  permissions {
    contents = "write"
    metadata = "read"
    pull_requests = "write"
    administration = "read"
  }
}