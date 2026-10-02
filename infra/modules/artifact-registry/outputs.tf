output "repository_id" {
  description = "Artifact Registry repository ID"
  value       = google_artifact_registry_repository.rclone.repository_id
}

output "repository_url" {
  description = "Full Docker image prefix URL"
  value       = "${google_artifact_registry_repository.rclone.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.rclone.repository_id}"
}
