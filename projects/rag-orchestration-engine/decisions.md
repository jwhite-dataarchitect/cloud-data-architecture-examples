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
| Disposable compute/database, persistent source/build assets | Reduce idle runtime cost while preserving inputs and reusable images | Final disposable Terraform state is empty and persistent source/image assets were verified; persistent assets still cost money |
| One GCE VM and Cloud SQL for the demonstration | Keep the cloud runtime small and understandable | No autoscaling or high availability; the VM has outbound internet access |
| IAP-only inbound access | Avoid exposing an unauthenticated API publicly | Depends on authorized Google identities and does not add application-level auth |
| Mock providers, real PostgreSQL in integration tests | Exercise database, retrieval, graph, and API integration without credentials or provider charges | Does not validate live provider responses; embedding semantics are not under test |
| Isolated ephemeral test Compose project | Prevent test teardown from stopping the development stack and avoid stale database state | Docker startup/build adds time; the fixed project name supports serial runs, not concurrent runs on the same host |
| GitHub Actions running the local unit/integration targets on Python 3.11 | Keep developer and CI commands aligned without provider secrets | The October 12 run passed 36 unit and 3 integration tests; one runtime version is not a support-matrix certification |
| Reviewed Terraform plans and separate state roots | Separate persistent foundation from destroyable runtime and make destructive changes explicit | Operator action and delayed cloud resource deletion remain operational concerns |
| Manual-only guarded teardown | Require explicit operator review and confirmation before deleting disposable resources | TTL labels do not delete resources; operators must run teardown and cost sweeps |
| Defer application authentication and PII controls for this demo | IAP restricts cloud ingress; use non-sensitive data until a later refactor | Direct/local access has no application authentication; provider requests include queries and retrieved text |
| Rehydration-only database recovery | Rebuild indexed documents from current durable GCS source objects | Requires provider embeddings; deleted or overwritten source objects cannot be recovered |
| Application provider spend controls | Use a 6,149-token conservative per-request ceiling and a $25 UTC-month GCS-backed ledger for application-managed calls | Byte-based token estimates and twice-reference-rate pricing are approximations; ledger bucket and runtime IAM are configured but not applied |
| Cloud budget notifications only | Signal cloud spend without automatically terminating services | Cloud spend may exceed the configured budget; it is not a hard cap |
| Documentation-only publication | Share architecture, trade-offs, diagram, and verified evidence separately from deployment configuration | Publication is complete; implementation, raw logs, identifiers, credentials, state, and plans stay outside this portfolio |

## Completed decisions and follow-ups

- [x] Resolve the graph framework as LangGraph and the interface as FastAPI.
- [x] Record implemented splitter defaults rather than leaving chunking choices
  marked undecided; quality tuning is a separate task.
- [x] Confirm one cloud query completed synthesis and grounding.
- [x] Complete the current Step 8 scope, commit/push the code, and verify CI.
- [x] Publish the four RAG case-study documents and architecture diagram on the
  portfolio default branch.
- [x] Resolve Decision 11 for the current demo: rely on IAP ingress and
  non-sensitive data; defer application authentication and PII controls until
  broader use.
- [x] Resolve Decisions 12-14: rehydration-only recovery, application provider
  spend controls, and manual-only guarded teardown.
- [x] Complete final guarded teardown and state/cost verification on October 14,
  2026. Asset Inventory returned one stale dev-bucket record last updated
  October 1; direct bucket lookup returned 404 and the current bucket listing
  had no matching bucket. The later cost follow-up preserved an unmanaged
  bucket containing one 49-byte object because ownership was unclear. Three
  obsolete Artifact Registry tags were removed and immutable-tag protection
  restored, but eight untagged manifests remain after dependency and permission
  errors. Active Secret Manager versions remain enabled by user direction.

## Remaining decisions and work

- [ ] Verify live GCS ingestion and decide whether Dagster partitioning is
  needed; local GCS integration remains mock-based.
- [ ] Implement real query routing, an embedding cache, and metadata-filtered
  retrieval.
- [ ] Implement application authentication and PII controls before broader use.
- [ ] Apply the configured provider ledger bucket and runtime IAM before
  enabling provider-backed cloud calls under the new spend controls.
- [ ] Cloud drift-and-repair/live fault tests remain unperformed; prior no-change
  plans and local mocked faults do not close this validation gap.
- [ ] Full live golden answer/grounding evaluation, representative quality/load
  testing, and measured lifecycle targets remain unverified.
- [ ] Document state access/recovery, Artifact Registry cleanup policy and
  permissions, and source-data operational retention before team use.

## Production evolution

Before production use, add application authentication and authorization, privacy
and retention controls, provider spend limits, model-quality evaluation,
database backups/recovery, workload-specific sizing, and operational SLOs.
Cloud drift repair remains untested. The demo teardown was verified for this
environment; repeat teardown verification after future infrastructure changes.
Current validation is a demonstration, not a production readiness assessment.

See [validation](validation.md) or return to the [project overview](README.md).
