terraform {
  required_version = ">= 1.6.0"
}

provider "google" {
  project                     = var.project_id
  impersonate_service_account = var.impersonate_service_account
}

module "iam" {
  source = "../../modules/iam"

  project_id = var.project_id
}

module "gcs" {
  source = "../../modules/gcs"

  project_id  = var.project_id
  environment = var.environment
  location    = var.bucket_location
}