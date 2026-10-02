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

# Cleanup untagged images after a configurable window (cost control).
# The window is parameterized: SHA-tagged images are never touched, so
# provenance/rollback is preserved regardless of the untagged TTL.
resource "google_artifact_registry_repository_cleanup_policy" "rclone_untagged" {
  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.rclone.name
  id         = "delete-untagged"
  action     = "DELETE"

  condition {
    tag_state  = "UNTAGGED"
    older_than = "${var.untagged_cleanup_days * 86400}s"
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
