# Terraform Cloud Initialization with Google Cloud Workload Identity

This directory contains the initialization scripts to set up Terraform Cloud with Google Cloud Workload Identity authentication. These scripts must be run **before** the infrastructure scripts.

## Overview

The init scripts will:

1. Create a Terraform Cloud workspace
2. Set up Google Cloud Workload Identity Pool and Provider
3. Create a service account for Terraform Cloud
4. Configure the necessary environment variables in Terraform Cloud
5. Enable auto-apply on git push for the infrastructure folder `/part-1/terraform/infrastructure`

## Prerequisites

Before running these scripts, ensure you have:

1. **Terraform Cloud Account**: Sign up at [app.terraform.io](https://app.terraform.io)
2. **Google Cloud Project**: Create a project in Google Cloud Console
3. **GitHub Repository**: Connected to your Terraform Cloud organization
4. **gcloud CLI**: Installed and authenticated (for fallback script)
5. **Terraform CLI**: Installed locally

## Setup Instructions

### Step 1: Configure Variables

1. Copy the example variables file:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your actual values:

   ```hcl
   terraform_cloud_organization_name = "your-terraform-cloud-org"
   terraform_cloud_project_name      = "your-project-name"
   terraform_cloud_workspace_name    = "your-workspace-name"
   github_organisation               = "your-github-username-or-org"
   github_repository                 = "your-repo-name"
   github_working_directory          = "part-1/terraform/infrastructure"

   google_project_id                 = "your-google-project-id"
   google_region                     = "europe-west2"  # London region
   workload_identity_pool_id         = "terraform-cloud-pool"
   workload_identity_provider_id     = "terraform-cloud-provider"
   service_account_id                = "terraform-cloud-sa"
   ```

### Step 2: Set Environment Variables

Set your Terraform Cloud token:

```bash
export TF_TOKEN_app_terraform_io="your-terraform-cloud-token"
```

For Google Cloud authentication, set:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/service-account-key.json"
# OR authenticate with gcloud
gcloud auth application-default login
```

### Step 3: Initialize and Run

1. Initialize Terraform:

   ```bash
   terraform init
   ```

2. Plan the deployment:

   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## What Gets Created

### Google Cloud Resources

1. **Workload Identity Pool**: `terraform-cloud-pool`

   - Allows external identity providers to authenticate to Google Cloud

2. **Workload Identity Provider**: `terraform-cloud-provider`

   - OIDC provider configured for Terraform Cloud
   - Maps Terraform Cloud tokens to Google Cloud identities

3. **Service Account**: `terraform-cloud-sa@PROJECT_ID.iam.gserviceaccount.com`
   - Used by Terraform Cloud to manage Google Cloud resources
   - Granted necessary IAM roles

### Terraform Cloud Resources

1. **Project**: Groups all related workspaces
2. **Workspace**: Configured with:
   - Auto-apply enabled
   - GitHub integration
   - Trigger patterns for infrastructure folder
   - Required environment variables for Workload Identity

### Environment Variables Set in Terraform Cloud

The following environment variables are automatically configured:

- `TFC_GCP_PROVIDER_AUTH=true`: Enables Workload Identity authentication
- `TFC_GCP_PROJECT_NUMBER`: Your Google Cloud project number
- `TFC_GCP_WORKLOAD_IDENTITY_POOL_ID`: Full resource name of the identity pool
- `TFC_GCP_WORKLOAD_IDENTITY_PROVIDER_ID`: Full resource name of the identity provider
- `TFC_GCP_SERVICE_ACCOUNT_EMAIL`: Email of the service account to impersonate

## Fallback: Manual Setup

If the Terraform-managed setup doesn't work, you can use the manual bash script:

1. Set required environment variables:

   ```bash
   export GOOGLE_PROJECT_ID="your-google-project-id"
   export TFC_ORGANIZATION_NAME="your-terraform-cloud-org"
   export TFC_WORKSPACE_NAME="your-workspace-name"
   export WORKLOAD_IDENTITY_POOL_ID="terraform-cloud-pool"
   export WORKLOAD_IDENTITY_PROVIDER_ID="terraform-cloud-provider"
   export SERVICE_ACCOUNT_ID="terraform-cloud-sa"
   ```

2. Run the setup script:

   ```bash
   ./setup-workload-identity.sh
   ```

3. Manually add the output environment variables to your Terraform Cloud workspace.

## Troubleshooting

### Common Issues

1. **GitHub App Installation**:

   - Ensure you've installed the Terraform Cloud GitHub App
   - Check that the installation ID is correct

2. **Google Cloud Permissions**:

   - Verify your Google Cloud user has Project IAM Admin role
   - Ensure required APIs are enabled

3. **Terraform Cloud Token**:
   - Generate a user or team token in Terraform Cloud
   - Set it as `TF_TOKEN_app_terraform_io` environment variable

### Verifying Setup

After running the init scripts, verify:

1. Workspace exists in Terraform Cloud
2. Environment variables are set correctly
3. Service account has required permissions
4. Workload Identity binding is active

## Next Steps

After successful initialization:

1. Navigate to the `../infrastructure/` directory
2. Configure your infrastructure resources
3. Push changes to trigger auto-apply

## Security Notes

- Workload Identity is more secure than service account keys
- The setup follows Google Cloud security best practices
- Service account permissions can be adjusted based on your needs
- Consider using least-privilege access principles

## Resources

- [Terraform Cloud Workload Identity](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/gcp-configuration)
- [Google Cloud Workload Identity](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Terraform Cloud Environment Variables](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/variables)
