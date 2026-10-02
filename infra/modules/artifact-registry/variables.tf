variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "location" {
  type        = string
  description = "Artifact Registry location (region or multi-region)"
  default     = "us-central1"
}

variable "repository_id" {
  type        = string
  description = "Artifact Registry repository name"
  default     = "rclone-ingestion"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "tf_service_account_email" {
  type        = string
  description = "Email of the Terraform runner service account (needs push access)"
}

variable "untagged_cleanup_days" {
  type        = number
  description = "Days to keep untagged images before cleanup. SHA-tagged images are never affected."
  default     = 1

  validation {
    condition     = var.untagged_cleanup_days >= 1
    error_message = "untagged_cleanup_days must be at least 1 day."
  }
}
