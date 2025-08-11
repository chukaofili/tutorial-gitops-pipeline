resource "google_container_cluster" "primary" {
  name     = var.gke_cluster_name
  location = var.google_region

  depends_on = [
    google_project_service.required_apis
  ]

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  node_config {
    disk_size_gb = var.gke_node_disk_size
    disk_type    = var.gke_node_disk_type
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true

    master_global_access_config {
      enabled = true
    }
  }


  # Enable network policy
  network_policy {
    enabled = true
  }

  # Maintenance window
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  # Enable workload identity
  workload_identity_config {
    workload_pool = "${var.google_project_id}.svc.id.goog"
  }

  identity_service_config {
    enabled = true
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "${var.gke_cluster_name}-node-pool"
  location   = var.google_region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_node_count

  node_config {
    preemptible  = false
    machine_type = var.gke_machine_type
    disk_size_gb = var.gke_node_disk_size
    disk_type    = var.gke_node_disk_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = var.environment
    }

    tags = [var.environment]

    // Enable workload identity on the node pool
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  network_config {
    enable_private_nodes = true
  }
}

# Service account for GKE nodes
resource "google_service_account" "gke_service_account" {
  account_id   = "${var.gke_cluster_name}-sa"
  display_name = "GKE Service Account"
  description  = "Service account for GKE cluster nodes"
}

# IAM bindings for the GKE service account
resource "google_project_iam_member" "gke_service_account_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/secretmanager.secretAccessor",
  ])

  project = var.google_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}
