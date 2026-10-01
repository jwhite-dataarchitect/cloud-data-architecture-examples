#!/usr/bin/env bash
#
# bootstrap.sh — one-time setup for the GCP demo foundation.
#
#   1. Resolves the canonical project ID (accepts project ID or number)
#   2. Enables the APIs Terraform and the demo need
#   3. Creates the `terraform-runner` service account if missing
#   4. Grants your gcloud user permission to impersonate it
#
# Usage:
#   ./scripts/bootstrap.sh [PROJECT_ID_OR_NUMBER]
#   GCP_PROJECT_ID=my-project ./scripts/bootstrap.sh

set -euo pipefail

PROJECT_INPUT="${1:-${GCP_PROJECT_ID:-}}"
if [[ -z "${PROJECT_INPUT}" ]]; then
  echo "ERROR: provide a project ID or number as the first argument or via GCP_PROJECT_ID." >&2
  exit 1
fi

SA_NAME="terraform-runner"

echo ">> Resolving project ID for '${PROJECT_INPUT}'..."
PROJECT_ID="$(gcloud projects describe "${PROJECT_INPUT}" --format='value(projectId)')"
echo ">> Using project: ${PROJECT_ID}"

SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"
CALLER="$(gcloud config get-value account)"

echo ">> Setting active project..."
gcloud config set project "${PROJECT_ID}"

echo ">> Enabling required APIs..."
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  sts.googleapis.com \
  storage-api.googleapis.com \
  bigquery.googleapis.com \
  --project "${PROJECT_ID}"

echo ">> Creating service account '${SA_EMAIL}' (if missing)..."
if ! gcloud iam service-accounts describe "${SA_EMAIL}" --project "${PROJECT_ID}" >/dev/null 2>&1; then
  gcloud iam service-accounts create "${SA_NAME}" \
    --display-name "Terraform runner (IaC)" \
    --project "${PROJECT_ID}"
else
  echo ">> Service account already exists, skipping."
fi

echo ">> Granting ${CALLER} permission to impersonate ${SA_EMAIL}..."
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
  --project "${PROJECT_ID}" \
  --member "user:${CALLER}" \
  --role "roles/iam.serviceAccountTokenCreator"

cat <<EOF

Bootstrap complete.

Next steps:
  1. cd infra/envs/dev
  2. cp terraform.tfvars.example terraform.tfvars
  3. In terraform.tfvars set:
       project_id                  = "${PROJECT_ID}"
       impersonate_service_account = "${SA_EMAIL}"
  4. terraform init && terraform plan
EOF