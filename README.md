# Ingestion Orchestration

Cloud-native data ingestion pipeline on GCP. Containerized rclone jobs orchestrated via Cloud Run, infrastructure as Terraform, least-privilege IAM throughout.

**Current Status**: Day 4 complete — Smoke test passed (v0.1.1 image running in Cloud Run).  
**Architecture**: GCS landing zone → Containerized rclone → Artifact Registry → Cloud Run Job

## Architecture

```mermaid
graph LR
    A[Tailscale/NAS<br/>Future] -->|SMB/HTTPS| B[rclone Container]
    C[Simulated Source<br/>GCS/HTTP] --> B
    B -->|Checksums| D[GCS Landing Bucket<br/>data-arch-demo-landing-dev]
    B -.->|Image Pull| E[Artifact Registry<br/>rclone-ingestion]
    F[Cloud Scheduler<br/>Day 6] -->|Triggers| G[Cloud Run Job<br/>rclone-ingestion-dev]
    G --> B
    H[Secret Manager<br/>Day 5] -.->|rclone.conf| B
```

## Quick Start

```bash
# Deploy infrastructure
cd infra/envs/dev
terraform init && terraform apply

# Build and push image (amd64 for Cloud Run)
cd ingestion/rclone
docker buildx build --platform linux/amd64 \
  -t us-central1-docker.pkg.dev/data-arch-demo/rclone-ingestion/rclone-ingestion:v0.1.1 \
  --push .

# Execute job
gcloud run jobs execute rclone-ingestion-dev \
  --region=us-central1 --project=data-arch-demo --wait
```

## Implementation Status

| Day | Deliverable | Status | Evidence |
|---|---|---|---|
| 1 | Terraform scaffold + local tooling | ✅ | `terraform validate` green |
| 2 | GCP project, IAM, landing bucket | ✅ | `gs://data-arch-demo-landing-dev` |
| 3 | rclone container + sync scripts | ✅ | `ingestion/rclone/Dockerfile`, dry-run verified |
| 4 | Registry + Cloud Run Job | ✅ | Execution `rclone-ingestion-dev-6vtzp`, logs show `rclone v1.75.1` on `linux/amd64` |
| 5 | Secret Manager + real transfer | ⬜ | — |
| 6 | Scheduling + idempotency + alerting | ⬜ | — |
| 7 | Teardown rehearsal + docs | ⬜ | — |

## Day 3 Details: RClone Configuration

*Operational specifics for the ingestion layer*

- **Remote name**: `gcs`
- **Auth**: `env_auth = true` (Application Default Credentials)
- **Storage class**: STANDARD
- **Config template**: `ingestion/rclone/config/rclone.conf.template`

**Dry-run test:**
```bash
./ingestion/rclone/scripts/test-local.sh
```

**Manual sync:**
```bash
./ingestion/rclone/scripts/sync-data.sh \
  --source /path/to/file.csv \
  --dest "gcs:data-arch-demo-landing-dev/landing/$(date +%Y/%m/%d)/"
```

**Cost controls:** Always `--dry-run` first; use `--bwlimit` for large files; monitor with `gcloud storage du -s gs://data-arch-demo-landing-dev`.

## Day 4 Details: Smoke Test Evidence

*Verification that the pipeline executes*

- **Image**: `rclone-ingestion:v0.1.1` (digest `sha256:ec8572b9...`)
- **Platform**: `linux/amd64` (built via `buildx --platform`)
- **Execution**: `rclone-ingestion-dev-6vtzp` succeeded in 1m43s
- **Output**: `rclone v1.75.1`, `os/arch: amd64`, `exit(0)`

**War stories resolved**: IAM propagation races, Apple Silicon → amd64 manifest issues, tainted resource recovery. See `docs/implementation-notes.md` for the full audit trail.

## Next Steps (Roadmap)

- **Day 5**: Move `rclone.conf` to Secret Manager volume; first real config-driven transfer; Cloud Build CI pipeline
- **Day 6**: Cloud Scheduler triggers; idempotency manifest; log-based alerting  
- **Day 7**: Full teardown/apply cycle; cost documentation; production hardening checklist

## Infrastructure

- **Project**: `data-arch-demo` (dedicated, low-cost)
- **State**: Local Terraform state (remote state deferred to post-MVP)
- **IAM**: `terraform-runner@` SA with 7 curated roles (see `docs/implementation-notes.md` for grant history)

## License

MIT