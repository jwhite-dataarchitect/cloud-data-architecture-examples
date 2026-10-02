# Implementation Notes

## Project Overview
**Repository:** `jwhite-dataarchitect/ingestion-orchestration`
**Project focus:** Cloud-native ingestion orchestration on GCP — containerized rclone transfers triggered as Cloud Run Jobs, all infrastructure as Terraform.
**Primary goal:** Build small, low-cost, reproducible demos that can be spun up and torn down quickly. Portfolio-first: every component must be demonstrable and documented.

---

## Source of Truth
This document tracks:
- what has been completed (with evidence)
- current implementation decisions
- next steps for each remaining day
- risks, constraints, and checkpoints

Update this file as progress is made so future sessions can resume quickly.

---

## Status Dashboard

| Day | Theme | Status |
|---|---|---|
| 1 | Repo scaffold + local tooling | ✅ Complete |
| 2 | GCP foundation, IAM, landing bucket | ✅ Complete |
| 3 | RClone ingestion container | ✅ Complete |
| 4 | Artifact Registry + Cloud Run Job smoke test | ✅ Complete |
| 5 | Secrets + real config-driven transfer | ⬜ Next |
| 6 | Scheduling + idempotency + alerting | ⬜ Planned |
| 7 | Teardown rehearsal + README finale | ⬜ Planned |

---

## Days 1–4 Completion Log

### Day 1 — Scaffold
- Repo created, local folder structure under `ingestion-orchestration`
- Tooling verified: Terraform, Git, VS Code CLI, gcloud
- Terraform module stubs: `gcs`, `bigquery`, `iam`, `compute`; env root `infra/envs/dev`
- `terraform init` / `fmt -check` / `validate` all green

### Day 2 — GCP Foundation
- Dedicated project: `data-arch-demo` (isolated for cost/teardown)
- `terraform-runner@` SA created via `scripts/bootstrap.sh`; local state (remote state deferred)
- Landing bucket: `gs://data-arch-demo-landing-dev` via `modules/gcs`
- Least-privilege IAM via `modules/iam` role list pattern

### Day 3 — RClone Container
- `ingestion/rclone/Dockerfile`: base `rclone/rclone:1.75.1` (digest-pinned), non-root user, `scripts/` baked in
- Dry-run verified locally; sync scripts parameterized src/dst with safe-fail logging
- `cloudbuild.yaml` added (targets gcr.io — modernization deferred to Day 5)

### Day 4 — Artifact Registry + Cloud Run Job ✅
**Evidence:** execution `rclone-ingestion-dev-6vtzp` succeeded; logs show
`rclone v1.75.1`, `os/arch: amd64`, `exit(0)`; image `sha256:ec8572b9...`.

- `modules/artifact-registry`: repo `rclone-ingestion`, writer binding for terraform-runner
- `modules/cloud-run-job`: job `rclone-ingestion-dev` + dedicated execution SA `rclone-runner@`
- Docker cred-helper auth to `us-central1-docker.pkg.dev`; pushed `v0.1.0` (arm64 — rejected), rebuilt `v0.1.1` (amd64 — deployed)

**War stories (full detail in README):**
1. Provider addressing: use full `registry.terraform.io/hashicorp/google`, not the error message's deprecated shorthand
2. IAM least-privilege expansion ×3 — each new capability = one committed grant (see role history below)
3. IAM propagation race → `-target=module.iam` sequencing
4. Apple Silicon arm64 image rejected by Cloud Run → `buildx --platform linux/amd64`
5. Tainted + deletion-protected deadlock → `terraform untaint` when resource is healthy; two-pass flag flip when it must die

**terraform-runner role history (audit trail):**

| Day | Grant | Triggered by |
|---|---|---|
| 2 | storage.admin, bigquery.admin, iam.serviceAccountUser | Bootstrap |
| 4 | artifactregistry.admin | 403 creating repo |
| 4 | iam.serviceAccountAdmin | 403 creating execution SA |
| 4 | run.admin | 403 creating Cloud Run job |

---

## Architecture Decision: NAS/Tailscale descoped (Day 4 decision)

Original plan included Tailscale subnet routing to reach a home NAS.
**Decision:** dropped. Tailscale isn't installed; more importantly, VPN plumbing is the
least *demonstrable* part of the project — a portfolio reviewer can't verify a home NAS.

**Replacement:** the NAS becomes a config-driven rclone "remote". Day 5 uses a
simulated external source (second GCS bucket and/or public HTTP dataset). The job
definition is source-agnostic: swapping in a Tailscale-routed SMB remote later is a
pure config change, not an architecture change. Documented as Future Work.

**What replaces it in the schedule:** idempotency + scheduling (Day 6) — the features
that actually justify the name "orchestration".

---

## Day 5 Plan: Secrets + Real Config-Driven Transfer

### Objective
Replace the `rclone version` smoke test with a real, secrets-backed, config-driven transfer.

### Tasks
1. **Secret Manager**: store `rclone.conf`; mount into job via `volumes.secret`
   (schema already confirmed in provider docs dump from Day 4)
2. **entrypoint.sh env-prefix wiring**: `RCLONE_CONFIG_GCS_*` overlays so remotes
   can be tuned per-env without rebuilding the image
3. **Simulated external source**: public HTTP dataset or a second GCS bucket
   acting as "external SFTP"; destination = landing bucket
4. **First real transfer** with verification logging (file counts, checksums)
5. Modernize `cloudbuild.yaml` → push to Artifact Registry (not gcr.io),
   tag by `$SHORT_SHA`, keep `rclone version` test step; wire `gcloud builds
   submit` as the blessed build path (kills the arm64 failure mode structurally)

### Success criteria
- Job runs a real transfer with zero secrets in code/image/env logs
- Re-running the transfer is safe (precursor to Day 6 idempotency)
- Cloud Build produces a deployable image without local Docker

---

## Day 6 Plan: Scheduling + Idempotency + Alerting

### Objective
Turn the job into an orchestrated pipeline: scheduled, idempotent, observable.

### Tasks
1. **Cloud Scheduler** → triggers `rclone-ingestion-dev` on a cron
   (replaces manual `gcloud run jobs execute`)
2. **Idempotency**: manifest/state object in GCS recording completed transfers;
   re-runs skip already-ingested files (no duplicates)
3. **Alerting**: log-based metric on execution failure → notification (email)
4. Structured transfer logs (JSON lines: source, dest, bytes, duration, status)

### Success criteria
- Pipeline runs unattended on schedule
- Manual re-run after success = no-op (provable via logs + bucket state)
- A forced failure produces an alert

---

## Day 7 Plan: Teardown + README Finale

### Tasks
1. Full `terraform destroy` rehearsal (document the deletion_protection
   two-pass procedure — dev env keeps protection `false` by design)
2. Spin-up-from-zero test: fresh clone → bootstrap → apply → transfer runs
3. Cost table in README (resting cost/day, per-run cost)
4. README architecture diagram + "What I'd do at production scale" section
   (remote state, env promotion, VPC-SC, CMEK, Tailscale/SMB as Future Work)

### Success criteria
- `destroy` → `apply` round trip works from a clean checkout
- README tells the whole story without the chat history

---

## Constraints (unchanged)
- Keep cloud costs low; teardown quick and reliable
- Small datasets; prefer local verification before cloud execution
- Every capability grant documented; every war story written down

## Open Questions
- Day 5 source choice: public HTTP dataset vs. second GCS bucket as pseudo-external
- Cloud Scheduler SA: reuse `rclone-runner@` + `run.invoker`, or dedicated scheduler SA? (lean: dedicated)
- Idempotency manifest format: per-file ledger vs. per-batch marker object

## Next Update
Update after: Secret Manager mount working, first real transfer, Cloud Build submit green.