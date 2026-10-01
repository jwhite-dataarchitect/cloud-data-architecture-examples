variable "project_id" {
  type        = string
  description = "GCP project ID (or project number)"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. \"dev\")"
  default     = "dev"
}

variable "bucket_location" {
  type        = string
  description = "Location for GCS buckets — region or multi-region"
  default     = "US"
}

variable "impersonate_service_account" {
  type        = string
  description = "Optional: email of a service account to impersonate (avoids key files on disk). Set via terraform.tfvars or TF_VAR_impersonate_service_account."
  default     = null
}