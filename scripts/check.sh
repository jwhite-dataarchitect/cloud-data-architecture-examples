#!/usr/bin/env bash
#
# check.sh — sanity checks for the Terraform configuration and deployed resources.
#
# Always runs: terraform fmt -check (whole repo) and terraform validate (dev env).
# If resources have been applied, also verifies the landing bucket and the
# terraform-runner service account exist.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${REPO_ROOT}/infra/envs/dev"

echo ">> terraform fmt -check -recursive"
terraform -chdir="${REPO_ROOT}" fmt -check -recursive

echo ">> terraform init + validate (dev env)"
terraform -chdir="${ENV_DIR}" init -input=false >/dev/null
terraform -chdir="${ENV_DIR}" validate

# Post-apply checks (skipped automatically if nothing is deployed yet)
if terraform -chdir="${ENV_DIR}" output landing_bucket_name >/dev/null 2>&1; then
  BUCKET="$(terraform -chdir="${ENV_DIR}" output -raw landing_bucket_name)"
  SA_EMAIL="$(terraform -chdir="${ENV_DIR}" output -raw tf_service_account_email)"

  echo ">> Verifying landing bucket gs://${BUCKET} exists..."
  gcloud storage buckets describe "gs://${BUCKET}" >/dev/null

  echo ">> Verifying service account ${SA_EMAIL} exists..."
  gcloud iam service-accounts describe "${SA_EMAIL}" >/dev/null
else
  echo ">> No Terraform outputs yet — skipping post-apply checks."
fi

echo "All checks passed."