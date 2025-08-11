#!/bin/bash

# Setup Google Cloud Workload Identity for Terraform Cloud
# This script is a fallback option if the Terraform-managed setup doesn't work
# Run this script if you prefer to set up Workload Identity manually using gcloud CLI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required environment variables are set
check_required_vars() {
    print_status "Checking required environment variables..."
    
    local required_vars=(
        "GOOGLE_PROJECT_ID"
        "TFC_ORGANIZATION_NAME"
        "TFC_WORKSPACE_NAME"
        "WORKLOAD_IDENTITY_POOL_ID"
        "WORKLOAD_IDENTITY_PROVIDER_ID"
        "SERVICE_ACCOUNT_ID"
    )
    
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        print_error "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        echo ""
        echo "Please set these variables before running the script:"
        echo "export GOOGLE_PROJECT_ID=\"your-google-project-id\""
        echo "export TFC_ORGANIZATION_NAME=\"your-terraform-cloud-org\""
        echo "export TFC_WORKSPACE_NAME=\"your-workspace-name\""
        echo "export WORKLOAD_IDENTITY_POOL_ID=\"terraform-cloud-pool\""
        echo "export WORKLOAD_IDENTITY_PROVIDER_ID=\"terraform-cloud-provider\""
        echo "export SERVICE_ACCOUNT_ID=\"terraform-cloud-sa\""
        exit 1
    fi
    
    print_success "All required environment variables are set"
}

# Check if gcloud is installed and authenticated
check_gcloud() {
    print_status "Checking gcloud CLI..."
    
    if ! command -v gcloud &> /dev/null; then
        print_error "gcloud CLI is not installed. Please install it first:"
        echo "https://cloud.google.com/sdk/docs/install"
        exit 1
    fi
    
    # Check if user is authenticated
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_error "You are not authenticated with gcloud. Please run:"
        echo "gcloud auth login"
        exit 1
    fi
    
    # Set the project
    gcloud config set project "$GOOGLE_PROJECT_ID"
    print_success "gcloud CLI is ready"
}

# Enable required APIs
enable_apis() {
    print_status "Enabling required Google Cloud APIs..."
    
    gcloud services enable \
        iam.googleapis.com \
        cloudresourcemanager.googleapis.com \
        iamcredentials.googleapis.com
    
    print_success "APIs enabled"
}

# Create Workload Identity Pool
create_workload_identity_pool() {
    print_status "Creating Workload Identity Pool..."
    
    if gcloud iam workload-identity-pools describe "$WORKLOAD_IDENTITY_POOL_ID" \
        --project="$GOOGLE_PROJECT_ID" \
        --location="global" &>/dev/null; then
        print_warning "Workload Identity Pool already exists"
    else
        gcloud iam workload-identity-pools create "$WORKLOAD_IDENTITY_POOL_ID" \
            --project="$GOOGLE_PROJECT_ID" \
            --location="global" \
            --display-name="Terraform Cloud Pool" \
            --description="Workload Identity Pool for Terraform Cloud"
        
        print_success "Workload Identity Pool created"
    fi
}

# Create Workload Identity Provider
create_workload_identity_provider() {
    print_status "Creating Workload Identity Provider..."
    
    if gcloud iam workload-identity-pools providers describe "$WORKLOAD_IDENTITY_PROVIDER_ID" \
        --project="$GOOGLE_PROJECT_ID" \
        --location="global" \
        --workload-identity-pool="$WORKLOAD_IDENTITY_POOL_ID" &>/dev/null; then
        print_warning "Workload Identity Provider already exists"
    else
        gcloud iam workload-identity-pools providers create-oidc "$WORKLOAD_IDENTITY_PROVIDER_ID" \
            --project="$GOOGLE_PROJECT_ID" \
            --location="global" \
            --workload-identity-pool="$WORKLOAD_IDENTITY_POOL_ID" \
            --display-name="Terraform Cloud Provider" \
            --description="OIDC identity pool provider for Terraform Cloud" \
            --issuer-uri="https://app.terraform.io" \
            --attribute-mapping="google.subject=assertion.sub,attribute.terraform_organization_id=assertion.terraform_organization_id,attribute.terraform_organization_name=assertion.terraform_organization_name,attribute.terraform_workspace_id=assertion.terraform_workspace_id,attribute.terraform_workspace_name=assertion.terraform_workspace_name,attribute.terraform_run_phase=assertion.terraform_run_phase,attribute.terraform_project_id=assertion.terraform_project_id,attribute.terraform_project_name=assertion.terraform_project_name" \
            --attribute-condition="assertion.terraform_organization_name==\"$TFC_ORGANIZATION_NAME\" && assertion.terraform_workspace_name==\"$TFC_WORKSPACE_NAME\""
        
        print_success "Workload Identity Provider created"
    fi
}

# Create Service Account
create_service_account() {
    print_status "Creating service account..."
    
    if gcloud iam service-accounts describe "$SERVICE_ACCOUNT_ID@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com" \
        --project="$GOOGLE_PROJECT_ID" &>/dev/null; then
        print_warning "Service account already exists"
    else
        gcloud iam service-accounts create "$SERVICE_ACCOUNT_ID" \
            --project="$GOOGLE_PROJECT_ID" \
            --display-name="Terraform Cloud Service Account" \
            --description="Service account for Terraform Cloud to manage Google Cloud resources"
        
        print_success "Service account created"
    fi
}

# Grant permissions to service account
grant_service_account_permissions() {
    print_status "Granting permissions to service account..."
    
    local roles=(
        "roles/compute.admin"
        "roles/storage.admin"
        "roles/iam.serviceAccountAdmin"
        "roles/resourcemanager.projectIamAdmin"
        "roles/container.admin"
        "roles/dns.admin"
    )
    
    for role in "${roles[@]}"; do
        gcloud projects add-iam-policy-binding "$GOOGLE_PROJECT_ID" \
            --member="serviceAccount:$SERVICE_ACCOUNT_ID@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com" \
            --role="$role"
    done
    
    print_success "Service account permissions granted"
}

# Bind service account to Workload Identity
bind_workload_identity() {
    print_status "Binding service account to Workload Identity..."
    
    gcloud iam service-accounts add-iam-policy-binding \
        "$SERVICE_ACCOUNT_ID@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com" \
        --project="$GOOGLE_PROJECT_ID" \
        --role="roles/iam.workloadIdentityUser" \
        --member="principalSet://iam.googleapis.com/projects/$(gcloud projects describe $GOOGLE_PROJECT_ID --format='value(projectNumber)')/locations/global/workloadIdentityPools/$WORKLOAD_IDENTITY_POOL_ID/attribute.terraform_workspace_name/$TFC_WORKSPACE_NAME"
    
    print_success "Workload Identity binding created"
}

# Display configuration details
display_configuration() {
    print_success "Workload Identity setup completed!"
    echo ""
    echo "Configuration details:"
    echo "======================"
    echo "Project ID: $GOOGLE_PROJECT_ID"
    echo "Project Number: $(gcloud projects describe $GOOGLE_PROJECT_ID --format='value(projectNumber)')"
    echo "Workload Identity Pool: projects/$(gcloud projects describe $GOOGLE_PROJECT_ID --format='value(projectNumber)')/locations/global/workloadIdentityPools/$WORKLOAD_IDENTITY_POOL_ID"
    echo "Workload Identity Provider: projects/$(gcloud projects describe $GOOGLE_PROJECT_ID --format='value(projectNumber)')/locations/global/workloadIdentityPools/$WORKLOAD_IDENTITY_POOL_ID/providers/$WORKLOAD_IDENTITY_PROVIDER_ID"
    echo "Service Account: $SERVICE_ACCOUNT_ID@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com"
    echo ""
    echo "You'll need to set these environment variables in your Terraform Cloud workspace:"
    echo "TFC_GCP_PROVIDER_AUTH=true"
    echo "TFC_GCP_PROJECT_NUMBER=$(gcloud projects describe $GOOGLE_PROJECT_ID --format='value(projectNumber)')"
    echo "TFC_GCP_WORKLOAD_IDENTITY_POOL_ID=projects/$(gcloud projects describe $GOOGLE_PROJECT_ID --format='value(projectNumber)')/locations/global/workloadIdentityPools/$WORKLOAD_IDENTITY_POOL_ID"
    echo "TFC_GCP_WORKLOAD_IDENTITY_PROVIDER_ID=projects/$(gcloud projects describe $GOOGLE_PROJECT_ID --format='value(projectNumber)')/locations/global/workloadIdentityPools/$WORKLOAD_IDENTITY_POOL_ID/providers/$WORKLOAD_IDENTITY_PROVIDER_ID"
    echo "TFC_GCP_SERVICE_ACCOUNT_EMAIL=$SERVICE_ACCOUNT_ID@$GOOGLE_PROJECT_ID.iam.gserviceaccount.com"
}

# Main execution
main() {
    echo "============================================"
    echo "Google Cloud Workload Identity Setup"
    echo "for Terraform Cloud"
    echo "============================================"
    echo ""
    
    check_required_vars
    check_gcloud
    enable_apis
    create_workload_identity_pool
    create_workload_identity_provider
    create_service_account
    grant_service_account_permissions
    bind_workload_identity
    display_configuration
}

# Run main function
main "$@"