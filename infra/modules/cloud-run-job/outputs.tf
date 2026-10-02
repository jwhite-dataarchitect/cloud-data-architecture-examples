output "job_name" {
  description = "Name of the Cloud Run job"
  value       = google_cloud_run_v2_job.job.name
}

output "service_account_email" {
  description = "Execution service account email"
  value       = google_service_account.job_runner.email
}