variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "job_name" {
  type        = string
  description = "Name of the Cloud Run job"
}

variable "location" {
  type        = string
  description = "Region for the job"
  default     = "us-central1"
}

variable "image" {
  type        = string
  description = "Full container image URL including tag"
}

variable "service_account_id" {
  type        = string
  description = "Account ID for the job's dedicated execution service account"
  default     = "rclone-runner"
}

variable "command" {
  type        = list(string)
  description = "Container entrypoint override (empty = use image ENTRYPOINT)"
  default     = []
}

variable "args" {
  type        = list(string)
  description = "Arguments passed to the entrypoint"
  default     = []
}

variable "timeout" {
  type        = string
  description = "Max execution time per attempt (e.g. 600s)"
  default     = "600s"
}

variable "max_retries" {
  type        = number
  description = "Task retry count on failure"
  default     = 0
}

variable "labels" {
  type        = map(string)
  description = "Resource labels"
  default     = {}
}

variable "deletion_protection" {
  type        = bool
  description = "Prevent accidental deletion of the job. Set true in prod."
  default     = true
}