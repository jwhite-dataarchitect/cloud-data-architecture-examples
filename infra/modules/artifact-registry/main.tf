# Artifact Registry repository for RClone ingestion images

resource "google_artifact_registry_repository" "rclone" {
  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = "Docker repository for RClone ingestion container"
  format        = "DOCKER"

  labels = {
    env        = var.environment
    managed_by = "terraform"
    purpose    = "container-registry"
  }
}


# Allow the terraform-runner SA to push images
resource "google_artifact_registry_repository_iam_member" "terraform_writer" {
  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.rclone.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${var.tf_service_account_email}"
}
