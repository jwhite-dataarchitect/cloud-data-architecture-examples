# Implementation Notes

## Project Overview
**Repository:** `jwhite-dataarchitect/cloud-data-architecture-examples`  
**Project focus:** Cloud data architecture examples using Terraform IaC, starting with GCP and expanding later to Azure and AWS.  
**Primary goal:** Build small, low-cost, reproducible demos that can be spun up and torn down quickly.

---

## Source of Truth
This document tracks:
- what has already been completed
- current implementation decisions
- next steps for each day
- risks, constraints, and checkpoints

Update this file as progress is made so future sessions can resume quickly.

---

## Completed Today

### Repository and local setup
- Created GitHub repository: `jwhite-dataarchitect/cloud-data-architecture-examples`
- Established local folder structure under `ingestion-orchestration`
- Installed and verified:
  - Terraform
  - Git
  - VS Code CLI (`code`)
  - Google Cloud CLI (`gcloud`)
- Fixed local Mac permission issues affecting:
  - `~/.config`
  - `~/.zshrc`
- Configured GitHub authentication using a Personal Access Token and macOS Keychain credential helper

### Day 1 scaffold
- Created repo scaffold for:
  - `README.md`
  - `docs/`
  - `scripts/`
  - `infra/modules/gcs`
  - `infra/modules/bigquery`
  - `infra/modules/iam`
  - `infra/modules/compute`
  - `infra/envs/dev`
- Added minimal Terraform root configuration in `infra/envs/dev`
- Ran and passed:
  - `terraform init`
  - `terraform fmt -check -recursive`
  - `terraform validate`
- Added Terraform module stub files for:
  - `gcs`
  - `bigquery`
  - `iam`
  - `compute`

### Current status
- Day 1 scaffold is complete
- Repo is connected to GitHub and pushed
- Ready to begin Day 2 work

---

## Day 2 Plan: GCP Foundation, IAM, and Landing Storage

### Objective
Create the minimal GCP environment needed for the project while keeping cost low and teardown simple.

### Tasks
1. Decide the GCP project strategy
   - Use a dedicated GCP project for this demo work
   - Keep project boundaries isolated for cost and cleanup simplicity

2. Decide Terraform state strategy
   - Start with a simple bootstrap approach
   - Move to remote state in GCS after the landing bucket exists

3. Create Terraform service account
   - Use a dedicated service account for IaC actions
   - Grant only the minimal roles required

4. Create landing GCS bucket
   - This bucket will serve as the raw ingestion landing zone
   - Enable cost controls and cleanup-friendly settings

5. Add IAM bindings
   - Limit privileges to what the project requires
   - Avoid broad editor/owner access

6. Add bootstrap and teardown scripts
   - `scripts/bootstrap.sh`
   - `scripts/teardown.sh`

7. Add sanity checks
   - Terraform formatting
   - Terraform validation
   - Post-apply checks for bucket and service account existence

### Day 2 success criteria
- GCP demo foundation exists
- Terraform can create and destroy the core resources
- Landing bucket is usable for ingestion work
- Cost controls are documented and enforced

---

## Day 3 Plan: RClone Ingestion Layer

### Objective
Build the ingestion mechanism that can move or sync data into GCS in a reproducible, containerized way.

### Tasks
1. Choose a small, low-cost dataset/source
   - Prefer a synthetic or public dataset
   - Keep transfer size small for testing

2. Build the RClone container
   - Create a Dockerfile
   - Package `rclone` in a repeatable runtime

3. Create sync/copy scripts
   - Support dry-run mode
   - Parameterize source and destination
   - Log clearly and fail safely

4. Add sanity checks / tests
   - Container builds successfully
   - Dry-run works
   - Sync script behaves as expected
   - Optional one-time live transfer to GCS for verification

5. Document the ingestion pattern
   - Explain why RClone is used
   - Explain cost and teardown considerations
   - Explain how it fits into the larger architecture

### Day 3 success criteria
- RClone container runs successfully
- Dry-run transfer is verified
- Small live transfer to GCS is verified
- Ingestion step is documented and reproducible

---

## Decisions So Far

### Technical choices
- Infrastructure as Code: Terraform
- Cloud focus: GCP first
- Local development: VS Code on macOS
- Ingestion tooling: RClone
- Project strategy: low-cost, quick teardown, demo-oriented

### Architectural goals
- Reproducible infrastructure
- Modular Terraform design
- Clear separation of landing, staging, and downstream processing layers
- Future support for Airflow, Dataflow, and Dagster benchmarks

---

## Constraints
- Keep cloud costs low
- Make teardown quick and reliable
- Use small datasets for testing
- Prefer local verification before cloud execution
- Document patterns as they are added

---

## Open Questions
- Which GCP project will be used for the demo environment?
- Should Terraform bootstrap use local state first or a remote GCS backend from the start?
- What dataset/source should RClone use for the initial demo?
- Will Day 2 include remote state migration, or should that be deferred until after the landing bucket exists?

---

## Next Update
Update this file after:
- GCP project selection
- Terraform backend decision
- landing bucket creation
- RClone container implementation
- first successful dry-run or live sync

# Cloud Build configuration for RClone ingestion container
# Usage: gcloud builds submit --config=cloudbuild.yaml ingestion/rclone/

steps:
  # Build the RClone image
  - name: 'gcr.io/cloud-builders/docker'
    args: 
      - 'build'
      - '-t'
      - 'gcr.io/$PROJECT_ID/rclone-ingestion:$SHORT_SHA'
      - '-t'
      - 'gcr.io/$PROJECT_ID/rclone-ingestion:latest'
      - '.'
    dir: 'ingestion/rclone'

  # Test the image (dry-run)
  - name: 'gcr.io/$PROJECT_ID/rclone-ingestion:$SHORT_SHA'
    args: 
      - 'rclone'
      - 'version'
    env:
      - 'RCLONE_CONFIG=/config/rclone'

  # Push to Container Registry
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'gcr.io/$PROJECT_ID/rclone-ingestion:$SHORT_SHA'
  
  - name: 'gcr.io/cloud-builders/docker'
    args:
      - 'push'
      - 'gcr.io/$PROJECT_ID/rclone-ingestion:latest'

images:
  - 'gcr.io/$PROJECT_ID/rclone-ingestion:$SHORT_SHA'
  - 'gcr.io/$PROJECT_ID/rclone-ingestion:latest'

options:
  logging: CLOUD_LOGGING_ONLY

timeout: 600s