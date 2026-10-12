# Decisions and tradeoffs

| Decision | Reason | Tradeoff or production consideration |
|---|---|---|
| PostgreSQL plus pgvector | Keep vector storage and lexical retrieval in one database compatible with local and cloud deployments | PostgreSQL full-text ranking differs from BM25; managed database sizing and index behavior need workload validation |
| Dense and lexical retrieval | Provide semantic similarity and exact-term matching for different query/document characteristics | Two retrieval paths add database work and require ranking fusion |
| Reciprocal Rank Fusion, `k=60` | Combine ranked lists without calibrating heterogeneous raw scores | The constant is a design choice, not a tuned benchmark result |
| OpenAI `text-embedding-3-small`, 1536 dimensions | Match the implemented embedding client and database vector schema | External provider dependency, data egress, spend, and model-version compatibility |
| Gemini for synthesis and grounding | Separate answer generation from evidence review | Typically two model calls per query; review is not independent verification |
| Withhold unsupported answers | Avoid returning an answer when the grounding verdict is unsupported | Model-based verdicts may be wrong; provider or schema failures remain errors |
| Sequential LangGraph flow | Make router, retrieval, synthesis, and review stages explicit | Current router is a placeholder; sequential calls increase latency |
| Disposable compute/database, persistent source/build assets | Reduce idle runtime cost while preserving inputs and reusable images | Persistent assets still cost money; clean teardown is not yet fully verified |
| One GCE VM and Cloud SQL for the demonstration | Keep the cloud runtime small and understandable | No autoscaling or high availability; the VM has outbound internet access |
| IAP-only inbound access | Avoid exposing an unauthenticated API publicly | Depends on authorized Google identities and does not add application-level auth |
| Mock providers, real PostgreSQL in integration tests | Exercise database, retrieval, graph, and API integration without credentials or provider charges | Does not validate live provider responses; embedding semantics are not under test |
| Isolated ephemeral test Compose project | Prevent test teardown from stopping the development stack and avoid stale database state | Docker startup and image build make the integration suite slower than unit tests |
| Reviewed Terraform plans and separate state roots | Separate persistent foundation from destroyable runtime and make destructive changes explicit | Operator action and delayed cloud resource deletion remain operational concerns |
| Budget notifications only | Signal spend without automatically terminating services | Spend may exceed the configured budget; it is not a hard cap |

## Production evolution

Before production use, add application authentication and authorization, privacy
and retention controls, provider spend limits, model-quality evaluation,
database backups/recovery, workload-specific sizing, and operational SLOs.
Cloud drift repair and full teardown should be explicitly tested. Current
validation is a demonstration, not a production readiness assessment.

See [validation](validation.md) or return to the [project overview](README.md).
