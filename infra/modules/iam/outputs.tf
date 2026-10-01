output "tf_service_account_email" {
  description = "Email of the Terraform service"
  value       = data.google_service_account.terraform.email
}

output "tf_sa_roles" {
  description = "Roles granted to the Terraform service account"
  value       = var.tf_sa_roles
}