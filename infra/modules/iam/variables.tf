variable "project_id" {
  type        = string
  description = "data-arch-demo"
}

variable "tf_service_account_id" {
  type        = string
  description = "ID of the pre-existing Terraform service account. Created by scripts/bootstrap.sh"
  default     = "terraform-runner"
}

variable "tf_sa_roles" {
  type        = list(string)
  description = "Minimal project-level roles granted to the Terraform service account"
  default = [
    "roles/storage.admin",
    "roles/bigquery.admin",
    "roles/iam.serviceAccountUser"
  ]
}
