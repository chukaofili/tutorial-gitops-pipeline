# Enable required Google Cloud APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",              # Compute Engine API (required for GKE)
    "container.googleapis.com",            # Google Kubernetes Engine API
    "cloudresourcemanager.googleapis.com", # Cloud Resource Manager API
    "iam.googleapis.com",                  # Identity and Access Management API
    "logging.googleapis.com",              # Cloud Logging API
    "monitoring.googleapis.com",           # Cloud Monitoring API
    "serviceusage.googleapis.com",         # Service Usage API
    "servicenetworking.googleapis.com",    # Service Networking API (for private services)
    "secretmanager.googleapis.com",        # Secret Manager API
    "sqladmin.googleapis.com",             # Cloud SQL Admin API
  ])

  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false

  timeouts {
    create = "10m"
    update = "10m"
  }
}
