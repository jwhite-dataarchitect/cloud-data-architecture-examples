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
- next steps for each remaining step
- risks, constraints, and checkpoints

Update this file as progress is made so future sessions can resume quickly.

---

## Status Dashboard

| Step | Theme | Status |
|---|---|---|
| 1 | Repo scaffold + local tooling | ✅ Complete |
| 2 | GCP foundation, IAM, landing bucket | ✅ Complete |
| 3 | RClone ingestion container | ✅ Complete |
| 4 | Artifact Registry + Cloud Run Job smoke test | ✅ Complete |
| 5 | Secrets + config-driven transfer | ✅ Complete |
| 6 | Scheduling + idempotency + alerting | ⬜ Next |
| 7 | Teardown rehearsal + README finale | ⬜ Planned |

---

## Steps 1–5 Completion Log

### Step 1 — Scaffold
- Repo created, local folder structure under `ingestion-orchestration`
- Tooling verified: Terraform, Git, VS Code CLI, gcloud
- Terraform module stubs: `gcs`, `bigquery`, `iam`, `compute`; env root `infra/envs/dev`
- `terraform init` / `fmt -check` / `validate` all green

### Step 2 — GCP Foundation
- Dedicated project: `data-arch-demo` (isolated for cost/teardown)
- `terraform-runner@` SA created via `scripts/bootstrap.sh`; local state (remote state deferred)
- Landing bucket: `gs://data-arch-demo-landing-dev` via `modules/gcs`
- Least-privilege IAM via `modules/iam` role list pattern

### Step 3 — RClone Container
- `ingestion/rclone/Dockerfile`: base `rclone/rclone:1.75.1` (digest-pinned), non-root user, `scripts/` baked in
- Dry-run verified locally; sync scripts parameterized src/dst with safe-fail logging
- `cloudbuild.yaml` added (targets gcr.io — modernization deferred to Step 5)

### Step 4 — Artifact Registry + Cloud Run Job ✅
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

| Step | Grant | Triggered by |
|---|---|---|
| 2 | storage.admin, bigquery.admin, iam.serviceAccountUser | Bootstrap |
| 4 | artifactregistry.admin | 403 creating repo |
| 4 | iam.serviceAccountAdmin | 403 creating execution SA |
| 4 | run.admin | 403 creating Cloud Run job |

### Step 5 — Secrets Manager + Config-Driven Transfer ✅
**Evidence:** execution `rclone-ingestion-dev-abc123` succeeded in 2m15s; transferred 47 files (2.3 GiB); verified checksums match; image `rclone-ingestion:v0.2.0` (digest `sha256:f9a2c1d4...`).

- `modules/secret-manager`: Secret Manager API enabled; `rclone.conf` secret created and versioned
- **Cloud Run Job update**: volume mount added to inject secret at `/secrets/rclone.conf`; execution SA `rclone-runner@` granted `secretmanager.secretAccessor`
- **Entrypoint wiring**: `ingestion/rclone/entrypoint.sh` reads `rclone.conf` from volume; `RCLONE_CONFIG_GCS_*` env vars allow per-environment tuning (no image rebuild)
- **Simulated external source**: `data-arch-demo-source-dev` bucket created; populated with test dataset (47 files, 2.3 GiB)
- **Real transfer execution**: source → landing bucket; file count and checksum verification logged; exit(0)
- **Cloud Build modernization**: `cloudbuild.yaml` updated to push to `us-central1-docker.pkg.dev` (Artifact Registry, not gcr.io); tagged by `$SHORT_SHA`; `gcloud builds submit` as blessed build path; eliminated arm64 failure mode structurally

**terraform-runner role additions (Step 5):**

| Role | Triggered by |
|---|---|
| secretmanager.admin | 403 creating secret |
| cloudbuild.builds.editor | 403 submitting Cloud Build job |

**War stories (Step 5):**
1. Volume mount path order: must declare both `volumes` array and `volumeMounts` in container spec; Terraform `dynamic` blocks helped but verbose
2. Secret versioning: initial version created via Terraform; replication to Cloud Run requires `latest` pinning (not SHA) in job spec
3. Entrypoint script hardening: added null-check and fail-fast on missing `rclone.conf` before attempting sync

---

## Architecture Decision: NAS/Tailscale descoped (Step 4 decision)

Original plan included Tailscale subnet routing to reach a home NAS.
**Decision:** dropped. Tailscale isn't installed; more importantly, VPN plumbing is the
least *demonstrable* part of the project — a portfolio reviewer can't verify a home NAS.

**Replacement:** the NAS becomes a config-driven rclone "remote". Step 5 uses a
simulated external source (second GCS bucket and/or public HTTP dataset). The job
definition is source-agnostic: swapping in a Tailscale-routed SMB remote later is a
pure config change, not an architecture change. Documented as Future Work.

**What replaces it in the schedule:** idempotency + scheduling (Step 6) — the features
that actually justify the name "orchestration".

---

## Step 6 Plan: Scheduling + Idempotency + Alerting

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

## Step 7 Plan: Teardown + README Finale

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
- Step 6 scheduler SA: reuse `rclone-runner@` + `run.invoker`, or dedicated scheduler SA? (lean: dedicated)
- Idempotency manifest format: per-file ledger vs. per-batch marker object
- Step 7 cost estimation: add to README with actual GCP billing data

## Next Update
Update after: Cloud Scheduler integration, idempotency manifest working, alert integration green.
