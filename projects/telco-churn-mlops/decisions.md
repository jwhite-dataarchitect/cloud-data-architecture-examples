# Decisions and tradeoffs

**Status:** completed demonstration, owner-verified on October 18, 2026.

| Decision | Reason | Tradeoff or production consideration |
|---|---|---|
| Warehouse staging before training | Separate normalized analytical data and checks from fitting | Batch replacement needs source ownership and recovery controls |
| Preprocessing and classifier in one pipeline | Retain fitted transforms with the model and split before fitting | Artifact provenance, dependency compatibility, and feature order remain essential |
| Logistic regression baseline | Start with a compact, inspectable classifier | Ranking quality alone does not establish calibration, fairness, or business value |
| FastAPI with Pydantic | Express structured batch requests and probability responses | Production validation and access policies remain workload-specific |
| Dagster assets and scheduled retraining | Make data/model dependencies and recurring execution explicit | Runtime operations, monitoring, and recovery still need ownership |
| Cloud Run instead of Vertex AI endpoint serving | Fit the custom API without adopting Vertex AI's strict container conventions and required parameters | Model packaging and serving behavior remain application responsibilities |
| Registration distinct from inference | Keep model lifecycle records separate from the serving runtime choice | A registry entry is not itself a deployment or promotion policy |
| Federated CI authentication | Avoid a long-lived deployment key in GitHub | Keyless authentication is not a blanket least-privilege guarantee |
| Terraform-managed deployment IAM | Review identity relationships as configuration | Do not infer full environment coverage from one infrastructure file |
| Private code, public case study | Make reasoning and outcomes accessible without publishing implementation | Deeper implementation review requires an approved walkthrough |

## Serving-platform decision

Vertex AI was explored for online serving. Its container conventions and
parameter requirements introduced constraints that were unnecessary for this
demonstration's custom FastAPI path. Cloud Run became the final serving
platform, and the owner verified the resulting containerized inference flow.

This was an engineering tradeoff, not unfinished Vertex endpoint deployment.
Cloud Run and a model registry address different responsibilities; choosing
Cloud Run does not remove the need for deliberate model packaging and release
management.

## Engineering lessons

A saved model, registry upload, container build, and running API are distinct
lifecycle events. Their integration was part of the owner's completed
verification, not something established merely by the existence of those
components.

Evidence also has different sources. The owner used Gemini for coding,
testing, and verification, and Copilot for repository management and
documentation. The validation record preserves that distinction rather than
limiting the project status to Copilot's four local tests.

## Production considerations

Beyond the completed demonstration, broader use requires decisions about
authentication, authorization, model governance, monitoring, drift, recovery,
promotion/rollback, dependency reproducibility, and cost ownership.
These are production considerations, not a remaining project-completion list.

See [validation](validation.md) or return to the [project overview](README.md).
