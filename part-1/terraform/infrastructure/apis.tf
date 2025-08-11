# Enable required Google Cloud APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "container.googleapis.com",            # Google Kubernetes Engine API
    "sqladmin.googleapis.com",             # Cloud SQL Admin API
    "compute.googleapis.com",              # Compute Engine API (required for GKE)
    "cloudresourcemanager.googleapis.com", # Cloud Resource Manager API
    "iam.googleapis.com",                  # Identity and Access Management API
    "serviceusage.googleapis.com",         # Service Usage API
    "logging.googleapis.com",              # Cloud Logging API
    "monitoring.googleapis.com",           # Cloud Monitoring API
    "servicenetworking.googleapis.com"     # Service Networking API (for private services)
  ])

  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false

  timeouts {
    create = "10m"
    update = "10m"
  }
}
