# Architecture

![RAG data and control flow](../../assets/rag-orchestration-engine/architecture.svg)

## Data plane

The document path splits source text into chunks, generates 1536-dimensional
embeddings, and upserts content, metadata, hashes, and vectors into PostgreSQL.
Content hashes provide idempotent chunk identity. Durable source storage is
separate from the disposable query database.

The recursive character splitter defaults to 512 characters with 64-character
overlap, with constructor overrides available. The sample seed path uses
prewritten passages and bypasses splitting. Idempotent storage is not an
embedding cache: repeated ingest currently requests embeddings again. Automated
Dagster ingestion and source-to-database recovery remain unfinished.

The query path embeds the user's question, runs vector similarity and native
PostgreSQL full-text search, and combines the ranked results with Reciprocal
Rank Fusion (RRF). Content hashes de-duplicate chunks that appear in both
retrieval lists. The fused excerpts are numbered and passed to the answer
generator.

## Agent and API flow

The FastAPI endpoint invokes a sequential LangGraph flow:

1. Semantic router placeholder.
2. Hybrid PostgreSQL retriever.
3. Gemini answer synthesis using the numbered excerpts.
4. Separate Gemini grounding review.

The grounding review returns a structured verdict, reason, and unsupported
claims. A supported answer is returned; an unsupported answer is withheld and
reported as `insufficient_evidence`. Provider failures remain errors rather than
being converted into a successful or insufficient-evidence response.

The router currently accepts queries unconditionally. The grounding review is a
second model call and is not an independent truth oracle.

## Cloud and test control planes

The demonstration separates:

- **Disposable runtime:** one GCE API VM, private-IP Cloud SQL PostgreSQL,
  network, and runtime identity.
- **Persistent assets:** source-document storage, Artifact Registry, and secret
  containers.
- **State bootstrap:** a separately protected Terraform state bucket.

The VM accepts inbound SSH/API access only through IAP; it has external
connectivity for outbound package and model APIs. Local development uses Docker
Compose. The integration-test Compose project has a separate name and ephemeral
database volume; it runs the API through FastAPI's in-process test client rather
than a separate API container.

GitHub Actions runs the same unit/integration targets on pull requests and
pushes to the implementation's default branch. The October 12 run passed 36
unit and 3 integration tests. This verifies the current test harness, not live
provider behavior or a production deployment.

## Boundaries

- The deployment is a small demonstration, not a production availability or
  security certification.
- One live cloud query was verified; this is not a quality, scale, or latency
  benchmark.
- The local fault tests exercise application error mapping; no cloud drift
  repair or live cloud fault injection is claimed.
- Runtime teardown is partly complete. The final Private Service Access and
  VPC cleanup must wait for Cloud SQL producer-resource deletion.
- Persistent resources have a lifecycle separate from the disposable runtime
  and may continue to incur cost.

See [decisions and tradeoffs](decisions.md) and [validation](validation.md), or
return to the [project overview](README.md).
