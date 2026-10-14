# Validation evidence

**Evidence status:** October 14, 2026

**Scope:** local unit and integration tests; one deployed cloud runtime and one
provider-backed end-to-end query; partial cloud teardown.

| Check | Verified outcome |
|---|---|
| Offline unit suite | `make test` passed 36 unit tests locally and in the October 12 CI run |
| Integration suite | `make integration-test` passed 3 tests against an isolated PostgreSQL/pgvector service locally and in the October 12 CI run |
| Step 8 delivery and CI | Implementation commit `f2c31eb` is pushed to `main`; GitHub Actions run `38263718340` succeeded on October 12, including both test targets |
| Rehydration-only recovery and CI | Decision 12 is implemented in commit `9ff66d2`; GitHub Actions run `38590062294` passed `make test` and `make integration-test` |
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
| Final disposable teardown | **Pending.** The last audited Terraform state contained the dev VPC, reserved range, Private Service Access connection, and API service registrations while Cloud SQL producer resources age out; no new cloud audit was performed for this documentation update |
| Cloud drift repair | **Not performed.** No disposable runtime is currently running; local application fault tests are not cloud drift tests |

## Deferred teardown verification

The Cloud SQL deletion was recorded at 2026-10-10 03:00 UTC. Google Cloud
documents that producer resources can take up to four days to clear. The
earliest retry time has passed, but this documentation update did not run a
cloud audit. Do not force-delete the Private Service Access connection. Review
a fresh plan before retrying guarded teardown, then run the cost sweep. Confirm
the disposable Terraform state is empty, no dev VM or SQL instance remains,
and persistent resources are still present. Update this record with the
observed results; the checks are not represented as complete yet.

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
Existing local and CI results were reviewed for this documentation update;
no tests were rerun and no cloud resources were created or destroyed.
See [architecture](architecture.md) and
[the remaining decisions and work](decisions.md#remaining-decisions-and-work).
