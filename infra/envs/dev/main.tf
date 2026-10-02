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

module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id               = var.project_id
  tf_service_account_email = module.iam.tf_service_account_email
}

module "cloud_run_job" {
  source = "../../modules/cloud-run-job"

  project_id = var.project_id
  job_name   = "rclone-ingestion-dev"
  image      = "${module.artifact_registry.repository_url}/rclone-ingestion:v0.1.1"
  command    = ["rclone"]
  args       = ["version"]
  labels = {
    env        = "dev"
    managed_by = "terraform"
    purpose    = "ingestion-smoke-test"
  }
}