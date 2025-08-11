data "google_compute_network" "default" {
  name = "default"
  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_compute_global_address" "default_ip_range" {
  name          = "default-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.default.id

  depends_on = [
    google_project_service.required_apis
  ]
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.default.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.default_ip_range.name]

  depends_on = [
    google_project_service.required_apis,
    google_compute_global_address.default_ip_range
  ]
}


resource "google_sql_database_instance" "postgres" {
  name             = var.sql_instance_name
  database_version = "POSTGRES_17"
  region           = var.google_region

  depends_on = [
    google_project_service.required_apis,
    google_service_networking_connection.private_vpc_connection
  ]

  settings {
    tier              = var.sql_tier
    availability_type = "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = var.sql_disk_size

    backup_configuration {
      enabled                        = true
      start_time                     = "02:00"
      location                       = var.google_region
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 7
      }
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = data.google_compute_network.default.id
      enable_private_path_for_google_cloud_services = true
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }

    database_flags {
      name  = "log_min_duration_statement"
      value = "1000"
    }

    insights_config {
      query_insights_enabled  = true
      record_application_tags = true
      record_client_address   = true
    }

    maintenance_window {
      day          = 7
      hour         = 3
      update_track = "stable"
    }
  }

  # ignore changes to disk size, this is a workaround to avoid the issue where the disk size is not updated when the instance is updated
  lifecycle {
    ignore_changes = [settings[0].disk_size]
  }


  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}

resource "google_sql_database" "database" {
  for_each = toset([
    "notestack_db"
  ])
  name     = each.value
  instance = google_sql_database_instance.postgres.name
}

# Generate a random password for the postgres user
resource "random_password" "postgres_password" {
  length  = 16
  special = true
}

# Default postgres user
resource "google_sql_user" "postgres_user" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
  password = random_password.postgres_password.result
}

resource "google_secret_manager_secret" "postgres_host" {
  secret_id = "POSTGRES_HOST"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "postgres_host_version" {
  secret                 = google_secret_manager_secret.postgres_host.id
  secret_data_wo_version = 1
  secret_data_wo         = google_sql_database_instance.postgres.private_ip_address
}


resource "google_secret_manager_secret" "postgres_port" {
  secret_id = "POSTGRES_PORT"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "postgres_port_version" {
  secret                 = google_secret_manager_secret.postgres_port.id
  secret_data_wo_version = 1
  secret_data_wo         = "5432"
}


resource "google_secret_manager_secret" "postgres_username" {
  secret_id = "POSTGRES_USERNAME"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "postgres_username_version" {
  secret                 = google_secret_manager_secret.postgres_username.id
  secret_data_wo_version = 1
  secret_data_wo         = var.sql_user_name
}

resource "google_secret_manager_secret" "postgres_password" {
  secret_id = "POSTGRES_PASSWORD"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "postgres_password_version" {
  secret                 = google_secret_manager_secret.postgres_password.id
  secret_data_wo_version = 1
  secret_data_wo         = random_password.postgres_password.result
}

resource "google_sql_user" "users" {
  instance = google_sql_database_instance.postgres.name
  name     = var.sql_user_name
  password = random_password.postgres_password.result
}
