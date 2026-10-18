# Architecture

![Data, model, and delivery boundaries](../../assets/telco-churn-mlops/architecture.svg)

The diagram describes implementation responsibilities and intended handoffs,
not an inventory of deployed services. Dashed connections identify integration
work that has not been verified.

## Data plane

A local ingestion path normalizes column names and string values, converts
total charges to numeric values, and replaces a BigQuery staging table.
Warehouse checks cover key integrity, numerical nulls, target labels, and one
service-consistency condition.

The Dagster extraction asset reads staging directly. It does not invoke the
ingestion/validation entry point, so warehouse validation is not yet an
orchestrated prerequisite for retraining.

## Model lifecycle

Training selects 19 ordered features and a binary churn target, performs a
stratified train/test split, and fits numerical imputation/scaling,
categorical encoding, and logistic regression together. Keeping fitted
preprocessing inside the serialized pipeline reduces training/serving drift.
The reported evaluation metric is ROC-AUC; no measured score is published here.

Dagster defines extraction and dependent retraining assets with a Sunday
00:00 UTC schedule. A running scheduler, durable execution environment,
successful materialization, and failure recovery have not been verified.

Training also attempts inline registration. A separate registration path
uploads a serialized model to Cloud Storage before Vertex AI registration.
Their artifact names, image versions, and model selection conventions differ.
There is no verified, immutable training-to-registry handoff or quality gate.

## Online inference

FastAPI loads a local fitted pipeline at startup and accepts batches of typed
customer records. It returns a churn label and positive-class probability per
record. The runtime container packages an existing model file; it does not
retrieve a promoted registry version automatically.

A separate script targets managed Vertex AI endpoint serving. That path is
distinct from the FastAPI/Cloud Run container and is not invoked by the
application delivery workflow. Prebuilt-container compatibility remains
unverified.

## Identity and delivery

Terraform declares a deployment identity, project IAM bindings, and GitHub
OIDC federation scoped to the private implementation repository. Authentication
is keyless; current permissions are broader than a production least-privilege
design, and some role bindings overlap.

The delivery workflow defines tests, cloud authentication, a Cloud Build
submission, and Cloud Run deployment. Its image tag uses a container-registry
path, but Terraform does not declare an Artifact Registry repository. Project
creation, service enablement, model storage, and serving resources are also
outside the current Terraform definitions.

## Boundaries

- Typed fields do not enforce complete category domains, sensible numeric
  ranges, a nonempty batch, or a maximum batch size.
- Model quality, calibration, business thresholds, and drift monitoring are
  not established by the existing tests.
- Artifact naming and serving dependencies need reconciliation; registration
  is not promotion, and a weekly definition is not demonstrated automation.
- The workflow requests unauthenticated access, and the API has no
  application-level authentication or authorization. Access design is required
  before broader use.
- Replacing staging data requires recovery and ownership controls. Dedicated
  runtime identities, protected state, lifecycle management, and cost controls
  remain production considerations.
- No cloud resource identifiers, private endpoints, deployment commands,
  executable templates, or operator configuration are published here.

See [decisions and tradeoffs](decisions.md) or return to the
[project overview](README.md).
