# Validation evidence

**Evidence status:** October 12, 2026

**Scope:** local unit and integration tests; one deployed cloud runtime and one
provider-backed end-to-end query; partial cloud teardown.

| Check | Verified outcome |
|---|---|
| Offline unit suite | `make test` passed 36 unit tests in the recorded Phase 7 check |
| Integration suite | `make integration-test` passed 3 tests against an isolated PostgreSQL/pgvector service |
| Ingest-to-query integration | Real splitter, embedding adapter with deterministic vectors, PostgreSQL upsert, hybrid retrieval, LangGraph, and FastAPI request path completed with mocked Gemini calls |
| Database fault mapping | Simulated database failure returned an API error, not a success-shaped result |
| Gemini fault mapping | Simulated Gemini unavailability returned HTTP 503 |
| Test isolation | Test-specific Compose services and volume were removed after the run; the development database volume remained |
| Cloud migrations and startup | Migrations completed and the API started on the deployed VM |
| Health checks | `/health` passed locally and through IAP |
| Live query | One non-sensitive `POST /v1/query` completed retrieval, synthesis, and grounding with a supported verdict |
| Terraform plans | Persistent and disposable plans reported no changes before teardown |
| VM and database teardown | The approved guarded teardown removed the VM and Cloud SQL instance/database; cost audit found no VM or SQL instance |
| Final disposable teardown | **Pending.** Terraform still contains the dev VPC, reserved range, Private Service Access connection, and API service registrations while Cloud SQL producer resources age out |
| Cloud drift repair | **Not performed.** No disposable runtime is currently running; local application fault tests are not cloud drift tests |

## Deferred teardown verification

The Cloud SQL deletion was recorded at 2026-10-10 03:00 UTC. Google Cloud
documents that producer resources can take up to four days to clear. Do not
force-delete the Private Service Access connection. Retry the guarded dev
teardown no earlier than 2026-10-14 03:00 UTC, review a fresh plan, then run the
cost sweep. Confirm the disposable Terraform state is empty, no dev VM or SQL
instance remains, and persistent resources are still present. Update this
record with the observed results; the checks are not represented as complete
yet.

## What the results do not establish

- Three integration tests do not establish broad fault coverage, load capacity,
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
See [architecture](architecture.md) and [decisions](decisions.md).
