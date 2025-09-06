############################################
# 1) Generate an SSH keypair for Flux
############################################
# Flux will use this SSH key to access your GitHub repo.
# We generate an ECDSA P-256 key (modern, secure, and supported by GitHub).
resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

############################################
# 2) Add the public key to GitHub as a Deploy Key
############################################
# This creates a Deploy Key on your target GitHub repository so Flux
# running in the cluster can pull (and optionally push) to the repo.
resource "github_repository_deploy_key" "this" {
  # Helpful name so you can identify which cluster this key belongs to
  title = "flux-deploy-key-${var.flux_cluster_name}"

  # The FluxCD repository name (e.g., "fluxcd") — passed in via a Terraform var
  # This is where all the flux configuration and cluster state will be stored
  # PRs to the repository will be automatically applied to the cluster by fluxcd
  # This should be the same repository you created in part-1 -> provision the infra -> step 6
  repository = var.flux_repository

  # Use the public half of the key we just generated
  key = tls_private_key.flux.public_key_openssh

  # Flux Image Automation needs WRITE access to commit image updates back to Git.
  # NOTE: This should be a boolean. Prefer: read_only = false
  read_only = "false"

  # Ensure the key is generated before we try to create it on GitHub
  depends_on = [tls_private_key.flux]
}

############################################
# 3) Bootstrap Flux against the Git repo
############################################
# This installs Flux into the cluster and points it at your Git repo/path.
# Flux will reconcile whatever manifests live under the specified path.
resource "flux_bootstrap_git" "this" {
  # Path in the repo where cluster config lives, e.g., clusters/prod
  path = "part-2/flux/clusters/${var.flux_cluster_name}"

  # Include extra controllers for image automation (optional but common)
  components_extra = ["image-reflector-controller", "image-automation-controller"]

  # Make sure the GitHub deploy key exists before bootstrapping
  depends_on = [github_repository_deploy_key.this]
}

############################################
# Google Client Config (current gcloud context)
############################################
# This data source fetches details from your currently authenticated
# gcloud user or service account. It provides things like:
#  - The active project ID
#  - The active region/zone
#  - An OAuth2 access token (used by providers like Kubernetes/Flux)
#
# Terraform uses this so it knows *who* you are in Google Cloud
# and can reuse your credentials for API calls.
data "google_client_config" "default" {}

############################################
# 4) Kubernetes Provider (how Terraform talks to your cluster)
############################################
# Terraform needs cluster connection details to install Flux CRDs/resources.
# These values typically come from the GKE data source and your gcloud auth.
provider "kubernetes" {
  # API server endpoint for your GKE cluster
  host = "https://${google_container_cluster.primary.endpoint}"

  # OAuth2 access token from your local gcloud context / service account
  token = data.google_client_config.default.access_token

  # The cluster CA cert is base64-encoded by GKE; decode for the provider
  # NOTE: Be consistent: either use data.google_container_cluster or
  # google_container_cluster for both lines. This line references the resource.
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

############################################
# 5) Flux Provider (lets Terraform configure Flux itself)
############################################
# The Flux provider needs BOTH:
#  - Kubernetes connection (same cluster details as above)
#  - Git connection (where your cluster config lives)
provider "flux" {
  kubernetes = {
    # Same cluster endpoint and token used above
    host  = "https://${google_container_cluster.primary.endpoint}"
    token = data.google_client_config.default.access_token

    # NOTE: This line uses the *data* source for the CA cert.
    # Align with the kubernetes provider to avoid confusion.
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }

  git = {
    # SSH URL to your GitHub repo (org + repo provided via variables)
    url = "ssh://git@github.com/${var.github_organisation}/${var.flux_repository}.git"

    # Branch Flux should reconcile from (e.g., "main")
    branch = var.flux_repository_branch

    ssh = {
      # SSH username for Git over SSH is always "git" on GitHub
      username = "git"

      # Private key for the Deploy Key we generated above
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}
