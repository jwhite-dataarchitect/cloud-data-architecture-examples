# RAG orchestration engine

**Status as of October 14, 2026:** E2E query validated in an isolated cloud
demonstration; Step 8 code is committed/pushed and CI passed; Decisions 11-14
are resolved for the demo scope. The final disposable teardown is verified;
cloud drift validation remains open.

## The problem

Build a reproducible retrieval-augmented generation (RAG) demonstration that
combines semantic and lexical retrieval, produces cited answers from retrieved
evidence, and withholds answers that fail a separate grounding review. The
runtime should be inexpensive to recreate and safe to tear down without deleting
the durable source and build assets.

## My contribution

I designed and integrated the document processing and retrieval path, the
sequential agent graph and API, the PostgreSQL/pgvector data model, and separate
disposable and persistent infrastructure layers. I also added an isolated
database-backed integration-test stack and a CI workflow that run without cloud
credentials or paid model calls.

## Architecture summary

Documents are split into chunks and embedded before idempotent storage in
PostgreSQL. At query time, the API embeds the question, retrieves candidates
using vector similarity and PostgreSQL full-text search, fuses the ranked lists,
and asks Gemini to synthesize an answer from numbered excerpts. A separate
Gemini review checks the answer against those excerpts; unsupported answers are
withheld.

The cloud demonstration used one IAP-restricted VM for the API and private-IP
Cloud SQL for PostgreSQL. The local Compose stack and the disposable cloud
runtime are separate environments. Persistent source and image assets are
separated from the runtime so the compute and database can be destroyed
independently.

![RAG data and control flow](../../assets/rag-orchestration-engine/architecture.svg)

## Demonstrated outcomes

- Database migrations and application startup succeeded in the cloud runtime.
- Health checks succeeded locally and through IAP.
- One non-sensitive provider-backed query completed retrieval, synthesis, and
  grounding with a supported verdict.
- Offline unit tests and Docker-backed PostgreSQL integration tests passed;
  the integration flow uses deterministic embeddings and mocked Gemini calls.
- The October 12 GitHub Actions run for implementation commit `f2c31eb` passed
  36 unit and 3 integration tests. CI execution is verified, not merely configured.
- The Decision 13 implementation adds a conservative 6,149-token per-request
  ceiling and a persistent GCS-backed $25 UTC-month ledger for application-
  managed provider calls. The ledger bucket and runtime IAM are configured but
  have not been applied.
- The approved guarded teardown removed the remaining 11 disposable Terraform
  resources on October 14. The disposable state is empty, and Compute and Cloud
  SQL lists are empty. Persistent source storage, Artifact Registry, and Secret
  Manager entries remain.
- Google API services remain enabled by configuration; teardown removed their
  disposable Terraform registration resources without disabling the APIs.
- The cost sweep returned a historical Asset Inventory entry for a dev bucket
  last updated October 1. Direct bucket lookup returned 404 and the current
  bucket listing had no match, so the entry appears stale; no untracked bucket
  was deleted.

## Scope and access

This is a demonstration, not a production service, benchmark, or guarantee of
answer correctness. Grounding is model-based review, not independent proof of
truth. The router remains a placeholder, Dagster partitioning and live GCS
verification are incomplete, and the integration suite does not test a
separately deployed API container or live provider calls.

The current splitter uses 512-character chunks and 64-character overlap by
default, not token-based limits or quality-tuned thresholds. Sample seeding
loads prewritten passages rather than exercising that splitter. Content-hash
upserts prevent duplicate rows; an embedding cache is not implemented.

The API VM had IAP-only inbound access but an external IP for outbound package
and model access. Decision 11 defers application authentication and PII
controls until a later refactor; use only non-sensitive data and do not treat
this demo as suitable for broader deployment. Persistent cloud assets may
continue to incur cost; the cloud billing budget is notification-only. The
separate application provider ledger is an estimate, not a provider billing
record, and is not applied in the cloud. The disposable runtime is offline.

Implementation is maintained privately. This repository contains architecture
and validation evidence only; it omits project identifiers, endpoints,
credentials, Terraform state, plans, and operator-specific configuration.

See [the remaining decisions and closeout checklist](decisions.md#remaining-decisions-and-work)
for unresolved items; publication does not close those implementation or
validation gaps.

Continue to [architecture](architecture.md), [decisions](decisions.md), and
[validation](validation.md), or return to the [portfolio](../../README.md).
