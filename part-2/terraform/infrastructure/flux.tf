############################################
# Added for Part 2
############################################

############################################
# 1) Google Client Config (current gcloud context)
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
# 2) Kubernetes Provider (how Terraform talks to your cluster)
############################################
# Terraform needs cluster connection details to install Flux CRDs/resources.
# These values typically come from the GKE data source and your gcloud auth.
provider "kubernetes" {
  # API server endpoint for your GKE cluster
  host = "https://${google_container_cluster.primary.endpoint}"

  # OAuth2 access token from your local gcloud context / service account
  token = data.google_client_config.default.access_token

  # The cluster CA cert is base64-encoded by GKE; decode for the provider
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

############################################
# 3) Flux Provider (lets Terraform configure Flux itself)
############################################
# The Flux provider needs BOTH:
#  - Kubernetes connection (same cluster details as above)
#  - Git connection (where your cluster config lives)
provider "flux" {
  kubernetes = {
    # Same cluster endpoint and token used above
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }

  git = {
    # Https URL to your GitHub repo (org + repo provided via variables created from part-1)
    url = "https://github.com/${var.github_organization}/${var.flux_repository}.git"

    # Branch Flux should reconcile from (e.g., "main")
    branch = var.flux_repository_branch

    http = {
      username = "git"
      password = var.github_token
    }
  }
}

############################################
# 4) Bootstrap Flux against the Git repo
############################################
# This installs Flux into the cluster and points it at your Git repo/path.
# Flux will reconcile whatever manifests live under the specified path.
resource "flux_bootstrap_git" "this" {
  # Path in the repo where cluster config lives, e.g., clusters/prod
  path = "clusters/${var.flux_cluster_name}"

  # Include extra controllers for image automation (optional but common)
  components_extra   = ["image-reflector-controller", "image-automation-controller"]
  embedded_manifests = true

  # Make sure the Google Kubernetes Engine cluster exists before bootstrapping
  depends_on = [google_container_cluster.primary, google_compute_router_nat.main]
}
