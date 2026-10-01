# LLM Selection Matrix

This document is a practical guide for choosing the right model for the right task in this project. Model availability and naming change quickly, so the goal is to capture a durable decision framework rather than depend on any single vendor/version.

## Recommended Model-by-Task Matrix

| Use case | Best fit | Why |
|---|---|---|
| Agentic workflows / multi-step task execution | Claude | Strong at long-context reasoning, instruction following, and maintaining coherence across multiple steps. |
| Architecture decisions / tradeoff analysis | GPT-4.x / OpenAI reasoning models | Very good at structured thinking, comparing options, and explaining implications clearly. |
| Code generation / refactoring | Kimi / Kimi-style coding models | Often strong at producing code quickly and handling implementation-heavy tasks. |
| Documentation / README / runbooks | Claude or GPT-4.x | Good at clarity, structure, and turning rough notes into polished docs. |
| PR review / quality checks | Claude or GPT-4.x plus automated scanners | Helpful for summarizing findings, but should be paired with lint/security tools. |
| Security / compliance review | LLM + deterministic tools | Use the model for explanation and triage, but rely on scanners and policy tools for decisions. |
| Cost-sensitive repetitive work | Smaller/faster model | Good for summaries, formatting, tag cleanup, and simple transformations. |

---

## Practical Recommendations for This Project

### Planning and architecture
Use a strong reasoning model such as GPT-4.x or an equivalent OpenAI reasoning model when you need:
- project planning
- architecture decisions
- cost and tradeoff analysis
- implementation sequencing
- root-cause thinking

### Agentic task execution
Use Claude when you need:
- multi-step task completion
- long-context workflows
- file editing across a repo
- task continuity over several turns
- structured execution with less hand-holding

### Coding and refactoring
Use a coding-focused model such as Kimi or a similar coding-specialized model when you need:
- Terraform generation
- scripts
- boilerplate
- refactoring
- fast implementation work
- transformations across many files

### Documentation and writeups
Use Claude or GPT-4.x when you need:
- clean technical prose
- READMEs
- implementation notes
- architecture docs
- runbooks
- summaries for future context

### PR review and quality gates
Use an LLM for:
- code review summaries
- identifying likely issues
- explaining diffs in plain language
- creating review checklists

But always pair it with:
- linters
- tests
- security scanners
- dependency/CVE tools
- policy/compliance checks

### Security and compliance
Never rely on the model alone for approval decisions. Use the model to:
- explain findings
- prioritize risk
- summarize scan results
- suggest fixes

Then let deterministic tools and human review make the final call.

---

## Recommended Workflow Pattern

A safe and effective automation loop looks like this:

1. **Model proposes** a change or review finding
2. **Automated checks verify** the result
3. **Human approves** anything sensitive
4. **Merge or apply** the change
5. **Record the outcome** in docs or issue history

This pattern is especially important for:
- cloud infrastructure
- IAM changes
- secrets handling
- production deployments
- compliance-related workflows

---

## Project-Specific Guidance

For this repository, the suggested default is:

- **Planning and architecture:** GPT-4.x / OpenAI reasoning model
- **Agentic workflow execution:** Claude
- **Code generation and refactoring:** Kimi-style coding model
- **Documentation:** Claude or GPT-4.x
- **Security/compliance review:** LLM plus scanners and human approval
- **Repetitive low-risk tasks:** smaller/faster model

---

## Notes

- Model names and strengths evolve quickly, so revisit this matrix periodically.
- The best results usually come from using the model that matches the task, not forcing one model to do everything.
- For any destructive, security-sensitive, or cost-sensitive operation, keep a human in the loop.