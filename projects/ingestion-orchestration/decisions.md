# Decisions and tradeoffs

| Decision | Reason | Tradeoff or production consideration |
|---|---|---|
| Simulated source | Make the architecture demonstrable without a private source network | Does not prove private-network connectivity or every connector |
| Serverless job execution | Separate batch transfer execution from an always-running service | Startup latency and platform limits require workload-specific assessment |
| Attached execution identity | Avoid issuing and mounting a long-lived execution key | External connectors may require a different identity model |
| Configuration separate from infrastructure state | Keep private transfer payloads outside Terraform secret-version ownership | Configuration lifecycle becomes an explicit operational responsibility |
| Dedicated scheduler identity | Separate invocation from execution privileges | Additional IAM relationships need review |
| Cloud-native build | Avoid workstation architecture differences in deployed images | Build identity and supply-chain controls need separate hardening |
| Reviewed Terraform drift repair | Restore declared configuration after an out-of-band change | An operator must plan/apply; this is not autonomous self-healing |
| Failure-count alerting | Detect actual job errors and verify notification delivery | A missing-run heartbeat needs a separate policy |

## Lessons from live validation

IAM grants and new Monitoring metrics required propagation before downstream
operations succeeded. Declarative ordering cannot remove service propagation
delays. Diagnose specific failures rather than granting broad privileges as a
shortcut.

Structured application log levels and Cloud Logging severity are distinct.
The live fault tests established that execution-level errors matched the deployed
failure metric.

## Production evolution

Organization-specific IAM review, hardened build permissions, protected remote
state, retention controls, concurrency design, and environment promotion would
be required before a production deployment.

Future Dagster ETL work can reuse ingestion and infrastructure patterns while
adding transformation and asset-oriented orchestration. It is not part of the
validated scope here.

See [validation](validation.md) or return to the [project overview](README.md).
