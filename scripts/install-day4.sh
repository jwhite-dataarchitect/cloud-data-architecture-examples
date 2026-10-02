#!/usr/bin/env bash
#
# install-day4.sh — Install and verify Day 4 prerequisites (container tooling).
#
# Day 1–3 installed: Terraform, Git, VS Code CLI, gcloud.
# Day 4 adds:        Docker (local builds), Cloud Build API, Artifact Registry API.
#
# Usage:
#   ./scripts/install-day4.sh [PROJECT_ID_OR_NUMBER]
#
set -euo pipefail

PROJECT_INPUT="${1:-${GCP_PROJECT_ID:-}}"

echo ">> Checking Docker..."
if ! command -v docker >/dev/null 2>&1; then
  echo "   Docker not found. Installing via Homebrew..."
  if ! command -v brew >/dev/null 2>&1; then
    echo "ERROR: Homebrew is required to install Docker Desktop. Install from https://brew.sh" >&2
    exit 1
  fi
  brew install --cask docker
  echo "   Docker Desktop installed. Launching..."
  open -a Docker || true
  # Wait for daemon to accept connections (max 60 s)
  for _ in $(seq 1 12); do
    if docker info >/dev/null 2>&1; then
      break
    fi
    echo "   Waiting for Docker daemon..."
    sleep 5
  done
else
  echo "   Docker is installed: $(docker --version)"
fi

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker daemon is not running. Start Docker Desktop and retry." >&2
  exit 1
fi
echo "   Docker daemon is responsive."

if [[ -n "${PROJECT_INPUT}" ]]; then
  PROJECT_ID="$(gcloud projects describe "${PROJECT_INPUT}" --format='value(projectId)')"
  echo ">> Enabling Day 4 APIs in project: ${PROJECT_ID}"
  gcloud services enable \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com \
    --project "${PROJECT_ID}"
else
  echo ">> Skipping API enablement (no project provided)."
  echo "   Run later: gcloud services enable cloudbuild.googleapis.com artifactregistry.googleapis.com --project PROJECT_ID"
fi

echo ""
echo "Day 4 prerequisites complete."
echo "Next: docker build -t rclone-ingestion:test ingestion/rclone/"
