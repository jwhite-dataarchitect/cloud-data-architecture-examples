# Cloud Data Architecture Examples

A portfolio of cloud-native data architecture implementations showcasing infrastructure-as-code, containerization, orchestration, and least-privilege IAM across major cloud platforms.

## Projects

### 🔄 [Ingestion Orchestration](./ingestion-orchestration/)
**Status:** Step 5 complete — Secrets Manager + config-driven transfer verified

Cloud-native data ingestion pipeline on GCP. Containerized rclone jobs orchestrated via Cloud Run, infrastructure as Terraform, least-privilege IAM throughout.

- **Architecture**: GCS landing zone ← Containerized rclone (config via Secrets Manager) ← Artifact Registry ← Cloud Run Job
- **Tech Stack**: Terraform (HCL), Cloud Run, Artifact Registry, Secret Manager, GCS
- **Key Features**: Multi-step pipeline with real data transfers, secret-backed configuration, smoke-tested deployment
- **Entry Point**: `cd ingestion-orchestration && terraform apply`

---

## Coming Soon

*Additional cloud data architecture examples (Azure, AWS) launching Fall 2026*

---

## Quick Links

- **Ingestion Orchestration README**: [ingestion-orchestration/README.md](./ingestion-orchestration/README.md)
- **Implementation Notes**: [ingestion-orchestration/docs/implementation-notes.md](./ingestion-orchestration/docs/implementation-notes.md)
- **License**: MIT

---

## About

These examples are designed for quick spin-up and tear-down to minimize cloud costs. Each project includes full audit trails, war stories, and reproducible steps for portfolio review.
