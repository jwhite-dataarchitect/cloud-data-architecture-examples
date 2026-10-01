resource "google_storage_bucket" "landing" {
  name     = "${var.project_id}-landing-${var.environment}"
  project  = var.project_id
  location = var.location

  # No per-object ACLs; access is controlled purely through IAM
  uniform_bucket_level_access = true

  # Allow terraform destroy to remove the bucket even when it contains objects
  force_destroy = true

  # Cost control: landing data is transient, delete it automatically
  lifecycle_rule {
    condition {
      age = var.landing_retention_days
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    env        = var.environment
    managed_by = "terraform"
    purpose    = "landing"
  }
}