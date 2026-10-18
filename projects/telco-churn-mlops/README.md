# Telco churn MLOps

**Status as of October 18, 2026:** private implementation under development.
Four offline tests passed. Warehouse preparation, training, typed inference,
Dagster assets, and delivery configuration are implemented; full cloud
integration and model promotion remain unverified.

## The problem

Connect customer-data preparation to a repeatable churn-model lifecycle without
mixing model fitting into the online request path. The architecture needs clear
boundaries between staging quality, fitted preprocessing, retraining,
registration, and application delivery.

## My contribution

I designed the staging and validation flow, shared scikit-learn preprocessing
and classifier pipeline, typed inference API, Dagster extraction/retraining
assets, and keyless delivery configuration. I separated the data, model, and
deployment concerns while identifying the artifact and infrastructure gaps
that still prevent a verified end-to-end promotion workflow.

## Architecture summary

A CSV ingestion path normalizes customer data into BigQuery and runs warehouse
checks. Training splits data before fitting preprocessing and logistic
regression, evaluates ROC-AUC, and serializes the fitted pipeline. Dagster
defines warehouse extraction and retraining on a weekly schedule.

FastAPI provides a container-serving path. Separate scripts provide a Cloud
Storage/Vertex AI registration and endpoint path. GitHub Actions defines
tests, federated cloud authentication, image build, and Cloud Run deployment.
These paths currently have inconsistent artifact contracts; the schedule and
workflow definitions are not evidence of successful cloud execution.

![Telco churn data, model, and delivery boundaries](../../assets/telco-churn-mlops/architecture.svg)

## Verified outcomes

- Four existing offline tests passed on October 18.
- Feature extraction excludes the identifier and target for the sample data.
- Preprocessing produces a dense numerical representation of sample records.
- A preprocessing pipeline fitted on a subset transforms a held-out record.
- Source review established the component boundaries and remaining integration
  work; no live model-quality or deployment result is claimed.

## Scope and access

This is an engineering demonstration in development, not a production churn
service, benchmark, or guarantee of business impact. The tests do not cover
the API, live warehouse checks, model registration, scheduled execution, or
cloud deployment. Automated validation-to-training gating and
registration-to-serving promotion are not complete.

The API has typed fields, not complete domain validation or application
authentication. The delivery workflow requests unauthenticated service access.
Terraform currently covers deployment IAM and federation, not the full cloud
resource lifecycle. See the [architecture boundaries](architecture.md#boundaries)
before interpreting these components as a deployable system.

Implementation remains private, consistent with the other portfolio projects.
A technical walkthrough or client demonstration is available upon request
through the [portfolio contact](../../README.md#contact). Source, operational
configuration, cloud identifiers, data, model artifacts, and state are excluded.

Continue to [architecture](architecture.md), [decisions](decisions.md), and
[validation](validation.md), or return to the [portfolio](../../README.md).
