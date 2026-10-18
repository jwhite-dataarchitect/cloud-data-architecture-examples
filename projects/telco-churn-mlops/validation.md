# Validation evidence

**Completion and verification date:** October 18, 2026.

**Status:** completed demonstration. The project owner confirmed successful
verification through Gemini-assisted implementation and testing, including
resolution of the previously documented integration issues. Cloud Run replaced
Vertex AI as the final container-serving platform.

## Owner-confirmed outcomes

| Check | Confirmed outcome |
|---|---|
| Data preparation | Ingestion and warehouse validation completed and verified |
| Model training | Fitting, evaluation, serialization, and model handoff completed and verified |
| Registration | Registry upload and previously identified integration issues confirmed resolved |
| Dagster workflow | Extraction and scheduled retraining completed and verified |
| Inference | Containerized FastAPI inference verified on Cloud Run |
| Delivery and infrastructure | CI/CD and infrastructure verification completed for the demonstration |
| Serving-platform choice | Cloud Run selected in place of Vertex AI endpoint serving due to container conventions and parameter requirements |

These results are attributed to the owner's October 18 confirmation. Raw
cloud logs and run records were not independently reviewed by Copilot during
the documentation update. No additional test count, model score, performance
measurement, or teardown result was supplied for publication.

## Separately executed local checks

Copilot ran the four existing offline tests in a Python 3.11 environment:

- Feature/target extraction on sample records.
- Dense preprocessing output with the expected sample row count.
- A held-out transform using preprocessing fitted on a different subset.
- Local CSV fixture availability.

**Result:** four passed. The held-out transform is a smoke check, not an
exhaustive leakage assessment; fixture availability does not test cleaning.
These checks supplement the owner's broader verification rather than defining
the project's total coverage.

## Scope of the completion claim

The completed demonstration is not a production reliability, security,
fairness, predictive-quality, or business-impact certification. Numerical
benchmarks are not published without supplied measurements. Current cloud
inventory, continuing charges, and teardown status are not established by this
record.

Source, logs, datasets, model artifacts, Terraform state and plans, credentials,
cloud identifiers, and operator configuration remain private.
See [architecture](architecture.md) and
[production considerations](decisions.md#production-considerations).
