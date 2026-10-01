data "google_service_account" "terraform" {
  project    = var.project_id
  account_id = var.tf_service_account_id
}

resource "google_project_iam_member" "terraform_sa" {
  for_each = toset(var.tf_sa_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${data.google_service_account.terraform.email}"
}