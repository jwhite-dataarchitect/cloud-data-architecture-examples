# Telco churn MLOps

**Status as of October 18, 2026:** completed demonstration, verified by the
project owner through Gemini-assisted implementation and testing. Cloud Run
is the final container-serving platform.

## The problem

Connect customer-data preparation to a repeatable churn-model lifecycle without
mixing model fitting into online requests. The architecture needs clear
boundaries between staging quality, fitted preprocessing, retraining,
registration, and application delivery.

## My contribution

I designed and integrated warehouse staging and validation, shared scikit-learn
preprocessing and classification, a typed inference API, Dagster retraining
assets, and keyless delivery. I resolved the integration handoffs and selected
Cloud Run over Vertex AI endpoint serving to fit the custom API's container
requirements.

## Architecture summary

CSV preparation loads normalized customer data into BigQuery and runs warehouse
checks. Training splits data before fitting preprocessing and logistic
regression, evaluates ROC-AUC, and serializes the fitted pipeline. Dagster
organizes extraction and scheduled retraining.

FastAPI serves the fitted pipeline in a Cloud Run container. GitHub Actions
connects tests, federated cloud authentication, image build, and application
deployment. Model registration is distinct from online serving; Vertex AI's
strict serving-container conventions and required parameters led to the
decision to use Cloud Run for inference.

![Telco churn data, model, and delivery boundaries](../../assets/telco-churn-mlops/architecture.svg)

## Verified outcomes

The owner confirmed the following on October 18:

- Ingestion and warehouse validation completed successfully.
- Training, model serialization, registration, and integration handoffs were
  completed and verified.
- Dagster extraction and scheduled retraining were verified.
- Containerized FastAPI inference and delivery were verified on Cloud Run.
- Infrastructure and CI/CD verification completed for the demonstration.

Copilot separately ran four existing offline tests successfully. The
[validation record](validation.md) distinguishes those local checks from the
owner's broader Gemini-assisted verification; no numerical model score or
performance benchmark is published.

## Scope and access

This is a completed engineering demonstration, not a production churn service
or a guarantee of predictive quality or business impact. Production access
controls, model governance, reliability, and cost policies depend on the
intended operating environment.

Implementation remains private, consistent with the other portfolio projects.
A technical walkthrough or client demonstration is available upon request
through the [portfolio contact](../../README.md#contact). Source, operational
configuration, cloud identifiers, data, model artifacts, and state are excluded.

Continue to [architecture](architecture.md), [decisions](decisions.md), and
[validation](validation.md), or return to the [portfolio](../../README.md).
