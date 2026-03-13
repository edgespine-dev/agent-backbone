---
name: edgespine-deployment-router
description: classify EdgeSpine deployment and GitOps questions and route to the right repo docs and change locations.
---

# edgespine-deployment-router

## Purpose
Classify deployment/GitOps/Kubernetes questions in `bakerlabs-k8s` and route to the smallest correct document set and repo change location.

## Primary scope
- Problem classification.
- Document routing by source-of-truth priority.
- Initial change-location recommendation.

## Not responsible for
- Applying changes.
- Runtime remediation execution.
- Replacing specialist review skills.

## Read first
- `/home/esadmin/agent-backbone/skills/k8s/references/source-of-truth.md`
- `/home/esadmin/agent-backbone/skills/k8s/references/classification-and-guardrails.md`
- `/home/esadmin/agent-backbone/skills/k8s/references/conflict-matrix.md`
- `/home/esadmin/bakerlabs-k8s/docs/INDEX.md`
- `/home/esadmin/bakerlabs-k8s/README.md`
- `/home/esadmin/bakerlabs-k8s/docs/PROJECT_PLACEMENT.md`

## Workflow
1. Identify the main problem class.
2. Check for stale/missing/conflicting documentation signals using `conflict-matrix.md`.
3. Normalize only canonical layer terminology (`system|infrastructure|auth|web|agents`).
4. If legacy labels (`platform`, `app`) are used, route through placement docs and mark mapping as inference unless explicitly documented.
5. Select primary and secondary docs by source-of-truth order.
6. If policy cannot be resolved from repo docs, return `classification: documentation_conflict_or_gap`.
7. Produce a bounded conclusion and likely change location.

## Guardrails
- Do not present legacy layer mapping as confirmed repo policy without explicit citation.
- Prefer cautious routing with uncertainty over high-confidence guesses.
- If docs are conflicting or insufficient, stop short of prescriptive implementation guidance.

## Output contract
Return:
- `classification`
- `relevant_documents_consulted`
- `conclusion`
- `recommended_change_location`
- `guardrails_and_risks`
- `uncertainty_and_inference`
- `suggested_next_step`
