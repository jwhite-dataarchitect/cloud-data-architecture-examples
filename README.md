## Project Status

This repository is actively being developed as a living showcase of cloud data architecture patterns, starting with GCP and expanding later to Azure and AWS.

For the current implementation plan, daily progress, design decisions, and open questions, see [`docs/implementation-notes.md`](docs/implementation-notes.md).

### Current milestone
- Day 1 scaffold is complete
- Local tooling is installed and verified
- Terraform repo structure and module stubs are in place
- Ready to begin Day 2: GCP foundation, IAM, and landing storage

### Focus for the next work sessions
- Select or confirm the GCP demo project strategy
- Establish the Terraform state approach
- Create the landing GCS bucket
- Add minimal IAM/service account permissions
- Begin the RClone ingestion layer

# cloud-data-architecture-examples
Showcase of cloud data architecture examples using Terraform IaC — GCP first, with planned Azure/AWS examples. Designed for quick spin-up/tear-down to minimize cloud costs.

