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
      }
    }
  }
}