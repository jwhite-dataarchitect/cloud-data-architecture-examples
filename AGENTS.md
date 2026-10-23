# Portfolio publication standard

## Repository boundaries

- `jwhite-dataarchitect/cloud-data-architecture-examples` is the public,
  documentation-only portfolio, not a mirror of implementation repositories.
- The `telco-churn-mlops`, `rag-orchestration-engine`, and
  `ingestion-orchestration` code repositories are private and must remain private.
- Implementation code and demonstrations are available upon request for
  prospective clients or other approved reviewers. Do not publish code or change
  repository visibility without explicit authorization.

## Public audience and content

- Write for hiring managers, recruiters, and curious engineers. Explain the
  problem, the author's contribution, architecture, decisions, alternatives,
  tradeoffs, outcomes, limitations, and operational lessons.
- Follow the existing `projects/<project>/` case-study pattern: overview,
  architecture, decisions, and validation. Put diagrams in `assets/<project>/`.
- Match the existing RAG and ingestion case studies' writing conventions:
  concise, evidence-led prose, clear headings, explicit status and scope, and
  concrete engineering explanations rather than promotional claims.
- Ground claims in reviewed implementation and observed evidence. Distinguish
  implemented, tested, demonstrated, planned, and unresolved capabilities.
- Keep application source, deployable Terraform, CI/CD implementation, datasets,
  model artifacts, credentials, state, plans, and operator runbooks private.
  Describe their design publicly rather than copying executable files.
- Omit real cloud project IDs, project numbers, endpoints, service account
  addresses, and operator-specific configuration. Use neutral placeholders only
  when needed to explain the architecture.
- A request to showcase, mirror, or update a project's architecture means
  documentation and diagrams by default, not publication of implementation code.
- Base implementation examples in Google Cloud, using cloud-agnostic tools where
  appropriate. Discuss AWS and Azure only at the architecture level; do not
  present projects or implementations built for those platforms.
- Preserve the existing portfolio license and documentation-only boundary.
