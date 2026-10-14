# Decisions and tradeoffs

**Reconciled:** October 14, 2026. The following choices are resolved for the
current demonstration; related production capabilities and validation gaps
remain separately tracked below.

| Decision | Reason | Tradeoff or production consideration |
|---|---|---|
| PostgreSQL plus pgvector | Keep vector storage and lexical retrieval in one database compatible with local and cloud deployments | PostgreSQL full-text ranking differs from BM25; managed database sizing and index behavior need workload validation |
| Dense and lexical retrieval | Provide semantic similarity and exact-term matching for different query/document characteristics | Two retrieval paths add database work and require ranking fusion |
| Reciprocal Rank Fusion, `k=60` | Combine ranked lists without calibrating heterogeneous raw scores | The constant is a design choice, not a tuned benchmark result |
| OpenAI `text-embedding-3-small`, 1536 dimensions | Match the implemented embedding client and database vector schema | External provider dependency, data egress, spend, and model-version compatibility |
| Recursive character splitter, 512-character chunks and 64-character overlap by default | Record the implemented, overridable demo defaults | Not token-based or quality-tuned; the zero-overlap integration fixture and prewritten seed passages do not certify default chunking quality |
| Gemini for synthesis and grounding | Separate answer generation from evidence review | Typically two model calls per query; review is not independent verification |
| Withhold unsupported answers | Avoid returning an answer when the grounding verdict is unsupported | Model-based verdicts may be wrong; provider or schema failures remain errors |
| Sequential LangGraph flow | Make router, retrieval, synthesis, and review stages explicit | Current router is a placeholder; sequential calls increase latency |
| FastAPI query/health interface | Typed request/response contracts and explicit error mapping | No application authentication or persisted conversation checkpointing is implemented |
| Disposable compute/database, persistent source/build assets | Reduce idle runtime cost while preserving inputs and reusable images | Persistent assets still cost money; clean teardown is not yet fully verified |
| One GCE VM and Cloud SQL for the demonstration | Keep the cloud runtime small and understandable | No autoscaling or high availability; the VM has outbound internet access |
| IAP-only inbound access and non-sensitive demo data | Restrict cloud demo ingress and avoid processing sensitive data without application controls | The API has no application authentication/authorization or PII detection/redaction; queries go to OpenAI for embeddings and queries plus retrieved text go to Google Gemini. Require stronger access and privacy controls before broader or production use |
| Mock providers, real PostgreSQL in integration tests | Exercise database, retrieval, graph, and API integration without credentials or provider charges | Does not validate live provider responses; embedding semantics are not under test |
| Isolated ephemeral test Compose project | Prevent test teardown from stopping the development stack and avoid stale database state | Docker startup/build adds time; the fixed project name supports serial runs, not concurrent runs on the same host |
| GitHub Actions running the local unit/integration targets on Python 3.11 | Keep developer and CI commands aligned without provider secrets | The October 12 run passed 36 unit and 3 integration tests and the October 14 recovery-change run passed both targets; one runtime version is not a support-matrix certification |
| Reviewed Terraform plans and separate state roots | Separate persistent foundation from destroyable runtime and make destructive changes explicit | Operator action and delayed cloud resource deletion remain operational concerns |
| Budget notifications only | Signal spend without automatically terminating services | Spend may exceed the configured budget; it is not a hard cap |
| Documentation-only publication | Share architecture, trade-offs, diagram, and verified evidence separately from deployment configuration | Publication is complete; implementation, raw logs, identifiers, credentials, state, and plans stay outside this portfolio |

## Completed decisions and follow-ups

- [x] Resolve the graph framework as LangGraph and the interface as FastAPI.
- [x] Record implemented splitter defaults; quality tuning remains open because
  the available golden passages are too short to exercise overlap or
  long-document retrieval.
- [x] Confirm one cloud query completed synthesis and grounding.
- [x] Complete Decision 8 as a GCS-backed incremental ingestion asset with
  generation tracking and source deletion handling; live GCS access remains
  unverified.
- [x] Resolve Decision 12 as rehydration-only recovery for indexed documents
  from current GCS objects; deleted or overwritten objects are not recoverable.
- [x] Resolve Decision 11 for the demo: IAP-only cloud ingress, non-sensitive
  data only, and no application authentication or PII scrubbing; defer stronger
  controls until broader or production use.
- [x] Publish the four RAG case-study documents and architecture diagram on the
  portfolio default branch.

## Remaining decisions and work

- [ ] Decision 7: the implemented 512/64 defaults are not tuned against
  representative long-document retrieval; current golden passages are too short
  to exercise overlap.
- [ ] Select a schedule or manual-only trigger for the implemented Dagster
  ingestion asset.
- [ ] Implement real query routing, an embedding cache, and metadata-filtered
  retrieval.
- [ ] Decide and implement provider spend caps; per-call output limits and
  cloud budget notifications do not cap total provider spend.
- [ ] Decide manual-only versus scheduled teardown. Guarded manual teardown
  exists; TTL labels do not automatically delete resources.
- [ ] Complete delayed teardown, cost/state verification, and evidence update
  after October 14, 2026 at 03:00 UTC.
- [ ] Cloud drift-and-repair/live fault tests remain unperformed; prior no-change
  plans and local mocked faults do not close this validation gap.
- [ ] Full live golden answer/grounding evaluation, representative quality/load
  testing, and measured lifecycle targets remain unverified.
- [ ] Document state access/recovery, image cleanup, and source-data operational
  retention before team use.

## Production evolution

Before production use, add application authentication and authorization, privacy
and retention controls, provider spend limits, model-quality evaluation,
database backups/recovery, workload-specific sizing, and operational SLOs.
Cloud drift repair and full teardown should be explicitly tested. Current
validation is a demonstration, not a production readiness assessment.

See [validation](validation.md) or return to the [project overview](README.md).
