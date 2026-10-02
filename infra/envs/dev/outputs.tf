output "project_id" {
  description = "GCP project ID (or number) in use"
  value       = var.project_id
}

output "landing_bucket_name" {
  description = "Name of the landing bucket"
  value       = module.gcs.landing_bucket_name
}

output "landing_bucket_url" {
  description = "gs:// URL of the landing bucket"
  value       = module.gcs.landing_bucket_url
}

output "tf_service_account_email" {
  description = "Email of the Terraform service account"
  value       = module.iam.tf_service_account_email
}

output "artifact_registry_url" {
  description = "Docker image prefix URL for the rclone-ingestion repository"
  value       = module.artifact_registry.repository_url
}

output "source_bucket_name" {
  description = "Name of the simulated external source bucket (Day 5)"
  value       = google_storage_bucket.source.name
}