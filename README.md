## Project Status

This repository is actively being developed as a living showcase of cloud data architecture patterns, starting with GCP and expanding later to Azure and AWS.

For the current implementation plan, daily progress, design decisions, and open questions, see [`docs/implementation-notes.md`](docs/implementation-notes.md).

### Current milestone
- Day 1 scaffold is complete
- Local tooling is installed and verified
- Terraform repo structure and module stubs are in place
- Ready to begin Day 2: GCP foundation, IAM, and landing storage

### Focus for the next work sessions
- Select or confirm the GCP demo project strategy
- Establish the Terraform state approach
- Create the landing GCS bucket
- Add minimal IAM/service account permissions
- Begin the RClone ingestion layer

## Day 3: Data Ingestion with RClone

### Overview
RClone is configured to sync data to the GCS landing bucket (`data-arch-demo-landing-dev`) using service account impersonation via Application Default Credentials.

### Configuration
- **Remote name**: `gcs`
- **Config location**: `~/.config/rclone/rclone.conf`
- **Authentication**: `env_auth = true` (uses `gcloud auth application-default login`)
- **Storage class**: STANDARD (matches Terraform bucket configuration)

### Usage

**Dry-run test (no charges):**
```bash
./ingestion/rclone/scripts/test-local.sh
```

**Sync a file:**
```bash
./ingestion/rclone/scripts/sync-data.sh \
  --source /path/to/local/file.csv \
  --dest "gcs:data-arch-demo-landing-dev/landing/$(date +%Y/%m/%d)/"
```

**List files in bucket:**
```bash
rclone ls gcs:data-arch-demo-landing-dev/
```

**Sync with bandwidth limit (cost control):**
```bash
rclone copy /local/path gcs:data-arch-demo-landing-dev/path \
  --bwlimit 10M \
  --progress
```

### Directory Structure
```
ingestion/rclone/
├── scripts/
│   ├── sync-data.sh      # Main sync script
│   └── test-local.sh     # Dry-run test
├── config/
│   └── rclone.conf.template  # Configuration template
├── data/                 # Local test data (gitignored)
└── Dockerfile            # Container definition (pending Docker install)
```

### Cost Controls
- Always use `--dry-run` first to validate paths
- Use `--bwlimit` to prevent accidental large transfers
- Small test files (< 1KB) are effectively free
- Monitor usage: `gcloud storage du -s gs://data-arch-demo-landing-dev`

### Troubleshooting
- **"storageClass REGIONAL invalid"**: Ensure `storage_class = STANDARD` in rclone.conf
- **Authentication errors**: Run `gcloud auth application-default login`
- **Permission denied**: Verify service account impersonation is set up (Day 2)

### Next Steps (Day 4)
- Dockerize the ingestion process
- Set up Cloud Build triggers
- Add data validation hooks

# cloud-data-architecture-examples
Showcase of cloud data architecture examples using Terraform IaC — GCP first, with planned Azure/AWS examples. Designed for quick spin-up/tear-down to minimize cloud costs.

## Day 4 — Artifact Registry + Cloud Run Job (Smoke Test)

### What was built

| Component | Resource | Notes |
|---|---|---|
| Artifact Registry | `us-central1-docker.pkg.dev/data-arch-demo/rclone-ingestion` | Terraform module `modules/artifact-registry` |
| rclone image | `rclone-ingestion:v0.1.1` | linux/amd64, base `rclone/rclone:1.75.1` (digest-pinned), non-root user |
| Cloud Run Job | `rclone-ingestion-dev` | Module `modules/cloud-run-job`; `rclone version` smoke test |
| Execution SA | `rclone-runner@data-arch-demo.iam.gserviceaccount.com` | Dedicated runtime identity, created in-module |
| terraform-runner roles | 4 → 7 | Added: `artifactregistry.admin`, `iam.serviceAccountAdmin`, `run.admin` |

Smoke test verified via logs: `rclone v1.75.1`, `os/arch: amd64`, `exit(0)`,
execution `rclone-ingestion-dev-6vtzp`, image digest `sha256:ec8572b9...`.

### terraform-runner role history (audit trail)

| Day | Grant added | Triggered by |
|---|---|---|
| 2 | storage.admin, bigquery.admin, iam.serviceAccountUser | Bootstrap |
| 4 | artifactregistry.admin | 403 creating repo |
| 4 | iam.serviceAccountAdmin | 403 creating execution SA |
| 4 | run.admin | 403 creating Cloud Run job |

Pattern: each new GCP capability = one deliberate, committed grant in
`modules/iam/variables.tf`. `git log` on that file is the IAM audit trail.

### War stories / operational lessons

1. **Provider addressing.** Fresh provider install requires
   `registry.terraform.io/hashicorp/google` in `required_providers`. The error
   message suggesting `hashicorp/google` refers to the deprecated namespace —
   misleading; use the full registry path everywhere.

2. **API enablement lag.** New GCP APIs (`artifactregistry.googleapis.com`,
   `run.googleapis.com`) return "service not enabled" on first use. Enable via
   `gcloud services enable`, then retry. (Day 5+: manage via
   `google_project_service` resources in a bootstrap module.)

3. **IAM propagation races.** Terraform applies a role binding and a dependent
   resource in parallel; the dependent create can 403 before IAM propagates.
   Fix: `terraform apply -target=module.iam` first, then full apply. `-target`
   is for sequencing/recovery only, never routine use.

4. **arm64 → amd64 (Apple Silicon trap).** `docker build` on M-series Mac
   produces arm64 images; Cloud Run requires `amd64/linux` and rejects at job
   creation with `manifest ... must support amd64/linux`. Fix:
   `docker buildx build --platform linux/amd64 -t <url>:<tag> --push .`
   Structural fix (Day 5+): build in Cloud Build (`cloudbuild.yaml`) so local
   arch is irrelevant.

5. **Tainted + deletion-protected deadlock.** A job that fails async
   validation (bad image) is created-but-tainted. Replacement plans fold the
   `deletion_protection: true→false` change into the destroy, but the API
   still has protection ON → destroy always 403s, apply loops forever.
   Recovery: `terraform untaint <addr>` when the resource is actually fine
   (in-place update proceeds), or flip protection via API/gcloud when the
   resource must truly be destroyed. Two-pass by design.

### Key commands

```bash
# Cross-platform image build (from ingestion/rclone/)
docker buildx build --platform linux/amd64 \
  -t us-central1-docker.pkg.dev/data-arch-demo/rclone-ingestion/rclone-ingestion:vX.Y.Z \
  --push .

# Verify platform before deploying
docker buildx imagetools inspect <image-url>:<tag>   # want: linux/amd64

# Execute the job and watch
gcloud run jobs execute rclone-ingestion-dev \
  --region=us-central1 --project=data-arch-demo --wait

# Read execution logs
gcloud logging read "resource.type=cloud_run_job AND labels.\"run.googleapis.com/execution_name\"=<execution-id>" \
  --project=data-arch-demo --limit=20
```

### Known debt → Day 5

- [ ] `deletion_protection = true` for prod envs (dev intentionally `false`)
- [ ] Execution SA created inside job module — refactor to pass SA in from
      env composition root so `depends_on` can express IAM ordering
- [ ] Cloud Build-based image builds (cloudbuild.yaml exists; wire it up)
- [ ] `roles/artifactregistry.reader` on repo for `rclone-runner@` if/when
      explicit image-pull auth is needed (Gen2 platform pull sufficed today)
- [ ] Secret Manager: rclone.conf as volume mount (`volumes.secret` block)
- [ ] Tailscale subnet routing for NAS access
- [ ] entrypoint.sh env-prefix wiring (`RCLONE_CONFIG_GCS_*`)

