# Decisions and tradeoffs

| Decision | Reason | Tradeoff or production consideration |
|---|---|---|
| Warehouse staging before training | Separate normalization and data checks from model fitting | Full-table replacement needs source ownership, recovery, and schema enforcement |
| Preprocessing and classifier in one pipeline | Fit transforms on training data and retain them with the model | Artifact provenance, dependency compatibility, and ordered inputs remain essential |
| Logistic regression baseline | Start with a compact model before adding complexity | Ranking quality alone does not establish calibration, fairness, or business value |
| Ordered feature contract | Support array-oriented inference in a managed serving path | Positional inputs can silently drift without explicit contract tests |
| FastAPI with Pydantic | Express structured batch requests and probability responses | Type validation is not complete domain validation or access control |
| Dagster assets | Make warehouse extraction and retraining dependencies visible | Schedule activation, hosting, durable outputs, and failure recovery are separate responsibilities |
| Separate registration and endpoint scripts | Explore managed registry and serving capabilities independently | Divergent artifact contracts and two serving paths add integration overhead |
| Federated CI authentication | Avoid storing a long-lived deployment key in GitHub | Keyless authentication does not prove least privilege or safe runtime exposure |
| Terraform-managed identity relationships | Review deployment access as configuration | The current definitions do not yet manage the complete cloud stack |
| Private code, public case study | Make design reasoning and evidence accessible without publishing implementation | Demonstrations and deeper implementation review require an approved walkthrough |

## Engineering lessons

The important boundary is not simply whether components exist. A saved model,
a registry upload, an image build, and a running API are different lifecycle
events. They need a shared artifact identity and explicit promotion rules
before they form a repeatable delivery system.

Likewise, a passing preprocessing smoke test is narrower evidence than
warehouse quality, valid API behavior, successful scheduled training, or
deployment readiness. This case study records those distinctions rather than
describing configuration as a completed operational outcome.

## Remaining decisions and work

- Align artifact names, dependency versions, registry identity, and serving
  contracts; separate local training from cloud registration.
- Choose the intended serving path and define immutable artifact lineage,
  evaluation gates, promotion, and rollback.
- Make warehouse validation a training dependency and strengthen tests for
  leakage, invalid labels, feature order, API inputs, and inference failures.
- Centralize environment configuration and remove deployment-specific literals
  from reusable private components.
- Complete infrastructure declarations, review IAM scope, and establish
  dedicated runtime identities and protected state.
- Add durable scheduling, monitoring, cost ownership, and cloud fault/recovery
  evidence before making operational claims.

These are open engineering items, not capabilities delivered by publication.
See [validation](validation.md) or return to the [project overview](README.md).
