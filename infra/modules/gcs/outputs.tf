output "landing_bucket_name" {
  description = "Name of the landing bucket"
  value       = google_storage_bucket.landing.name
}

output "landing_bucket_url" {
  description = "gs:// URL of the landing bucket"
  value       = google_storage_bucket.landing.url
}