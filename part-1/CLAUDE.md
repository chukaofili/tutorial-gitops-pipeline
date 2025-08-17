# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a GitOps pipeline tutorial project demonstrating Terraform Cloud integration with Google Cloud using Workload Identity authentication. The project consists of two main phases:

1. **Initialization** (`terraform/init/`): Sets up Terraform Cloud workspace and Google Cloud Workload Identity
2. **Infrastructure** (`terraform/infrastructure/`): Manages actual Google Cloud resources like GKE clusters and Cloud SQL instances

## Project Structure

```
terraform/
├── init/                    # Terraform Cloud & Workload Identity setup
│   ├── README.md           # Detailed setup instructions
│   ├── gcp_workload_identity.tf   # Google Cloud Workload Identity resources
│   ├── tfc_workspace.tf    # Terraform Cloud workspace configuration
│   └── setup-workload-identity.sh # Fallback manual setup script
└── infrastructure/         # Main infrastructure resources
    ├── config.tf           # Terraform Cloud backend configuration
    ├── providers.tf        # Google Cloud provider configuration
    ├── variables.tf        # Input variables
    ├── gke.tf             # GKE cluster resources (empty - to be implemented)
    └── sql.tf             # Cloud SQL resources (empty - to be implemented)
```

## Common Commands

### Terraform Operations

```bash
# Initialize Terraform (run from terraform/infrastructure/ directory)
terraform init

# Plan infrastructure changes
terraform plan

# Apply changes (typically done via Terraform Cloud auto-apply)
terraform apply

# Format Terraform code
terraform fmt

# Validate configuration
terraform validate
```

### Setup Workflow

1. **First-time setup**: Run initialization from `terraform/init/` directory
2. **Infrastructure changes**: Work in `terraform/infrastructure/` directory
3. **Auto-deployment**: Changes pushed to GitHub trigger Terraform Cloud runs

## Architecture

### Authentication Flow

- Uses Google Cloud Workload Identity Federation (no service account keys)
- Terraform Cloud authenticates via OIDC tokens to Google Cloud
- Service account impersonation for resource management

### Key Components

- **Terraform Cloud**: Manages state, runs plans/applies, integrates with GitHub
- **Workload Identity Pool**: Enables external OIDC provider authentication
- **Service Account**: Executes Terraform operations with least-privilege IAM roles
- **GitHub Integration**: Auto-triggers on infrastructure directory changes

## Development Notes

### Prerequisites

- Terraform Cloud account and organization
- Google Cloud project with billing enabled
- GitHub repository with Terraform Cloud app installed
- Local `terraform.tfvars` file with project-specific values

### File Status

- `gke.tf` and `sql.tf` are currently empty placeholders
- Infrastructure resources need to be implemented based on tutorial requirements
- All Terraform files should follow existing variable and provider patterns

### Security Considerations

- Never commit service account keys or sensitive credentials
- Use Workload Identity Federation for secure cloud authentication
- Follow least-privilege principle for service account IAM roles
- Validate Terraform plans before applying in production

### Integration Points

- Changes to files in the infrastructure directory trigger Terraform Cloud runs
- Auto-apply is enabled for streamlined GitOps workflow
- Working directory is set to `terraform/infrastructure` in Terraform Cloud
