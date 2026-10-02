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

  project_id         = var.project_id
  job_name           = "rclone-ingestion-dev"
  image              = "${module.artifact_registry.repository_url}/rclone-ingestion:v0.1.1"
  command            = ["rclone"]
  args = ["--config", "/config/rclone/rclone.conf", "sync", "--gcs-bucket-policy-only", "source:${google_storage_bucket.source.name}/incoming/seed", "dest:${google_storage_bucket.destination.name}/ingested/"]
  secret_name        = google_secret_manager_secret.rclone_config.secret_id
  sa_key_secret_name = google_secret_manager_secret.rclone_sa_key.secret_id

  labels = {
    env        = "dev"
    managed_by = "terraform"
    purpose    = "ingestion-smoke-test"
  }
}

# --- Day 5: Simulated external source (stands in for SFTP/NAS/HTTP origin) ---

resource "google_storage_bucket" "source" {
  name          = "${var.project_id}-source-${var.environment}"
  project       = var.project_id
  location      = var.bucket_location
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    environment = var.environment
    purpose     = "source-simulator"
    managed_by  = "terraform"
  }
}

resource "google_storage_bucket_object" "seed_data" {
  name    = "incoming/seed/test-data.csv"
  bucket  = google_storage_bucket.source.name
  content = "id,name,value\n1,alpha,100\n2,beta,200\n3,gamma,300\n"
}

# Grant job's execution SA read access to the source bucket
# Placed after module.cloud_run_job: reads top-down in dependency order
resource "google_storage_bucket_iam_member" "rclone_runner_source_reader" {
  bucket = google_storage_bucket.source.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${module.cloud_run_job.job_runner_email}"
}

# Day 5: RClone configuration stored in Secret Manager
resource "google_secret_manager_secret" "rclone_config" {
  secret_id = "rclone-config"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = {
    environment = var.environment
    purpose     = "rclone-config"
  }
}

# Grant Cloud Run job access to read the secret
resource "google_secret_manager_secret_iam_member" "rclone_runner_secret_access" {
  secret_id = google_secret_manager_secret.rclone_config.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.cloud_run_job.job_runner_email}"
}

# Day 5: Service account key for rclone GCS authentication
resource "google_secret_manager_secret" "rclone_sa_key" {
  secret_id = "rclone-sa-key"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = {
    environment = var.environment
    purpose     = "rclone-sa-key"
  }
}

# NOTE: This secret version is created MANUALLY via gcloud
# (see scripts/create-sa-key.sh) because we don't want the key in Terraform state
# Terraform only manages the secret resource itself

# Grant Cloud Run job access to read the SA key secret
resource "google_secret_manager_secret_iam_member" "rclone_runner_sa_key_access" {
  secret_id = google_secret_manager_secret.rclone_sa_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.cloud_run_job.job_runner_email}"
}

# Day 5: Destination bucket for ingested data
resource "google_storage_bucket" "destination" {
  name          = "${var.project_id}-dest-${var.environment}-jw"
  project       = var.project_id
  location      = var.bucket_location
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    environment = var.environment
    purpose     = "ingestion-destination"
    managed_by  = "terraform"
  }
}

# Grant job's execution SA write access to the destination bucket
resource "google_storage_bucket_iam_member" "rclone_runner_dest_writer" {
  bucket = google_storage_bucket.destination.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.cloud_run_job.job_runner_email}"
}

resource "google_secret_manager_secret_version" "rclone_config" {
  secret      = google_secret_manager_secret.rclone_config.id
  secret_data = file("${path.module}/../../../ingestion/rclone/config/rclone.conf.production")
}

