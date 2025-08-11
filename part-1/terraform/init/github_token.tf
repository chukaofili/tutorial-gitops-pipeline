/*
  Creates a GitHub personal access token with repo admin permissions for use in Terraform Cloud workspace.
  This token is separate from the CLI token and will be used as GITHUB_TOKEN env var.
*/
resource "github_user_gpg_key" "terraform_cloud_token" {
  armored_public_key = github_repository_personal_access_token.terraform_cloud_token.token
}

resource "github_repository_personal_access_token" "terraform_cloud_token" {
  permissions {
    contents = "write"
    metadata = "read"
    pull_requests = "write"
    issues = "write"
    administration = "write"
  }
}