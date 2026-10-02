resource "google_service_account" "job_runner" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Cloud Run job runner: ${var.job_name}"
  description  = "Execution identity for the ${var.job_name} Cloud Run job (managed by Terraform)"
}

resource "google_cloud_run_v2_job" "job" {
  name     = var.job_name
  location = var.location
  project  = var.project_id

  deletion_protection = false

  labels = var.labels

  template {
    template {
      service_account = google_service_account.job_runner.email
      timeout         = var.timeout
      max_retries     = var.max_retries

      containers {
        image   = var.image
        command = var.command
        args    = var.args

        dynamic "volume_mounts" {
          for_each = var.secret_name != null ? [1] : []
          content {
            name       = "rclone-config"
            mount_path = "/config/rclone"
          }
        }

        dynamic "volume_mounts" {
          for_each = var.sa_key_secret_name != null ? [1] : []
          content {
            name       = "rclone-sa-key"
            mount_path = "/secrets"
          }
        }
      }

      dynamic "volumes" {
        for_each = var.secret_name != null ? [1] : []
        content {
          name = "rclone-config"
          secret {
            secret       = var.secret_name
            default_mode = 420 # 0644 octal
            items {
              version = "latest"
              path    = "rclone.conf"
            }
          }
        }
      }

      dynamic "volumes" {
        for_each = var.sa_key_secret_name != null ? [1] : []
        content {
          name = "rclone-sa-key"
          secret {
            secret       = var.sa_key_secret_name
            default_mode = 256 # 0400 octal (read-only for owner)
            items {
              version = "latest"
              path    = "sa-key.json"
            }
          }
        }
      }
    }
  }
}