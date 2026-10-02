#!/bin/bash
set -euo pipefail

PROJECT_ID="${1:-data-arch-demo}"
SA_EMAIL="rclone-runner@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Creating service account key..."
gcloud iam service-accounts keys create /tmp/rclone-sa-key.json \
  --iam-account="$SA_EMAIL" \
  --project="$PROJECT_ID"

echo "Uploading to Secret Manager..."
gcloud secrets versions add rclone-sa-key \
  --data-file=/tmp/rclone-sa-key.json \
  --project="$PROJECT_ID"

echo "Cleaning up local key file..."
rm /tmp/rclone-sa-key.json

echo "✅ SA key secret updated"
