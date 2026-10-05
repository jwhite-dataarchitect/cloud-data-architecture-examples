# Serverless ingestion orchestration

**Status:** E2E-validated demonstration on October 5, 2026.

## The problem

Demonstrate a repeatable, scheduled data-transfer workflow without depending on
a private source network. The design needed to connect ingestion, infrastructure,
identity, and operational monitoring while keeping deployment configuration
separate from the portfolio.

## My contribution

I designed and integrated the transfer runtime, modular infrastructure,
execution and scheduler identities, runtime configuration boundary, and failure
monitoring. I validated both normal operation and deliberate faults, including
repairing an out-of-band source-path change through a reviewed Terraform apply.

## Architecture summary

Cloud Scheduler invokes a containerized rclone job on Cloud Run. The attached
identity reads a simulated source and writes to a destination in Cloud Storage.
Secret Manager supplies runtime configuration. Cloud Logging and Monitoring
detect failures and notify an operator by email.

The simulated source makes the architecture demonstrable without exposing a
private network or proprietary connector configuration.

## Demonstrated outcomes

- Keyless execution transferred matching data.
- Unchanged-input execution did not rewrite the destination object.
- Real scheduler invocations launched successful executions.
- Deliberate faults produced logs, incidents, and email notifications.
- Terraform restored a drifted job path without deleting or replacing buckets.
- Recovery executions succeeded, with automatic incident closure and resolution email.
- Teardown completed and the Terraform state listing was empty.

## Scope and access

This is a demonstration, not a production system, benchmark, or exactly-once
processing guarantee. Warehouse loading and Dagster ETL are not implemented in
this project.

Implementation is maintained privately. A technical walkthrough is available
through the [portfolio contact](../../README.md#contact).

Continue to [architecture](architecture.md), [decisions](decisions.md), and
[validation](validation.md), or return to the [portfolio](../../README.md).
