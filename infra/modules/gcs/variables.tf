variable "project_id" {
  type        = string
  description = "data-arch-demo"
}

variable "environment" {
  type        = string
  description = "Environment using the bucket (e.g. \"dev\")"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Bucket location — a region (e.g. \"us-central1\") or multi-region (\"US\", \"EU\")"
  default     = "US"
}

variable "landing_retention_days" {
  type        = number
  description = "Cost control: objects in the landing bucket are deleted after this many days"
  default     = 7
}
