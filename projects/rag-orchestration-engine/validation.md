# Validation evidence

**Evidence status:** October 14, 2026

**Scope:** local unit and integration tests; one deployed cloud runtime and one
provider-backed end-to-end query; final guarded teardown of disposable
resources.

| Check | Verified outcome |
|---|---|
| Offline unit suite | `make test` passed 55 unit tests locally and in CI |
| Integration suite | `make integration-test` passed 5 tests against an isolated PostgreSQL/pgvector service locally and in CI |
| Step 8 delivery and CI | Implementation commit `f2c31eb` is pushed to `main`; GitHub Actions run `38263718340` succeeded on October 12, including both test targets |
| Publication | The case study, decisions, validation record, and architecture diagram were merged to portfolio `main` through [PR 1](https://github.com/jwhite-dataarchitect/cloud-data-architecture-examples/pull/1) on October 12 |
| Ingest-to-query integration | Real splitter, embedding adapter with deterministic vectors, PostgreSQL upsert, hybrid retrieval, LangGraph, and FastAPI request path completed with mocked Gemini calls |
| Database fault mapping | Simulated database failure returned an API error, not a success-shaped result |
| Gemini fault mapping | Simulated Gemini unavailability returned HTTP 503 |
| Test isolation | Test-specific Compose services and volume were removed after the run; the development database volume remained |
| Cloud migrations and startup | Migrations completed and the API started on the deployed VM |
| Health checks | `/health` passed locally and through IAP |
| Live query | One non-sensitive `POST /v1/query` completed retrieval, synthesis, and grounding with a supported verdict |
| Terraform plans | Persistent and disposable plans reported no changes before teardown |
| VM and database teardown | The approved guarded teardown removed the VM and Cloud SQL instance/database; cost audit found no VM or SQL instance |
| Final disposable teardown | On October 14, a reviewed plan destroyed the 11 remaining disposable Terraform resources, including the dev VPC, Private Service Access connection/range, and Terraform registration resources for enabled APIs. The apply completed without force options; APIs remain enabled by configuration and disposable state is empty |
| Cost sweep | No Compute instances or Cloud SQL instances remain. A historical Asset Inventory bucket record last updated October 1 was absent from direct lookup and the current bucket listing. A separate unmanaged bucket contains one 49-byte test object and was preserved because ownership is unclear |
| Artifact Registry follow-up | Three obsolete tags were removed and immutable-tag protection restored. The final tagged image remains; eight untagged manifests remain in the 386.689 MB repository after cleanup encountered a manifest dependency and an operation-level permission error |
| Persistent resources | The durable source bucket, Artifact Registry repository, and Secret Manager entries were verified to remain. Active secret versions remain enabled at the user's direction; no secret values were read. The separately configured provider-budget ledger bucket and runtime IAM have not been applied |
| Cost limits | Cloud budgets remain notification-only, not spend caps. This resource inventory did not query itemized billing or establish actual charges |
| Cloud drift repair | **Not performed.** No disposable runtime is currently running; local application fault tests are not cloud drift tests |

## Teardown verification

The guarded destroy used a fresh reviewed plan after the Cloud SQL producer
resource wait period. The disposable Terraform state is empty; Compute and
Cloud SQL inventory is empty; and persistent source, image, and Secret Manager
resources remain. The Asset Inventory bucket record is stale based on its
October 1 update time and the current storage API/list results. No force-delete
operation was used. Three old image tags were removed, but registry cleanup is
incomplete: eight untagged manifests remain and the repository still reports
386.689 MB. An unmanaged bucket with one 49-byte object and active Secret
Manager versions were intentionally retained. The provider-budget ledger
bucket and runtime IAM remain configured but unapplied.

## What the results do not establish

- Five integration tests do not establish broad fault coverage, load capacity,
  or production reliability.
- Deterministic embeddings prove the database and retrieval plumbing, not
  embedding quality.
- Mocked Gemini calls verify application contracts and error mapping, not live
  model correctness. The one cloud query is a smoke check, not an answer-quality
  benchmark.
- Terraform no-change plans were observed before teardown; no intentional cloud
  drift-and-repair experiment was completed.
- Removing the VM and SQL instance does not imply that all cloud resources are
  gone. Persistent assets remain, and the budget only sends notifications.
- No production availability, security, privacy, or cost guarantee is claimed.

Raw logs, Terraform state and plans, account identifiers, private endpoints,
credentials, and local operator configuration are intentionally excluded.
The October 14 teardown and inventory checks were performed for this update.
No cloud resources were created; the disposable resources listed above were
destroyed.
See [architecture](architecture.md) and
[the remaining decisions and work](decisions.md#remaining-decisions-and-work).
