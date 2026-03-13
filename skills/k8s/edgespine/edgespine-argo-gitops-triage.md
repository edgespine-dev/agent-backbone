---
name: edgespine-argo-gitops-triage
description: perform read-only triage for EdgeSpine ArgoCD and GitOps sync/drift/access issues.
---

# edgespine-argo-gitops-triage

## Purpose
Provide read-only triage for ArgoCD sync/drift/access issues with repo-specific routing and safe next checks.

## Primary scope
- Sync/drift/access problem classification.
- Argo doc routing and likely root-cause narrowing.
- Safe read-only verification command suggestions.

## Not responsible for
- Executing sync/rollback/remediation.
- Mutating Argo application state.
- Credential rotation.

## Read first
- `/home/esadmin/agent-backbone/skills/k8s/references/source-of-truth.md`
- `/home/esadmin/agent-backbone/skills/k8s/references/classification-and-guardrails.md`
- `/home/esadmin/agent-backbone/skills/k8s/references/conflict-matrix.md`
- `/home/esadmin/bakerlabs-k8s/README.md`
- `/home/esadmin/bakerlabs-k8s/bootstrap/125_argocd_access.md`
- `/home/esadmin/bakerlabs-k8s/bootstrap/126_argo_github_access.md`

## Notes
- Treat `bootstrap/126_argo_github_access.md` as canonical for repo access wiring.
- `bootstrap/125_argocd_access.md` is known to include stale/conflicting details (missing `160` reference and local access mismatch); mark this explicitly when used.

## Workflow
1. Classify issue as `argo_gitops_sync_problem`.
2. Determine if issue is access, source URL, appset generation, or sync drift.
3. Check whether source docs are stale/missing/conflicting before concluding.
4. Route to minimal authoritative docs, preferring `126` for repo access wiring.
5. Provide read-only checks and expected signals.
6. If repo docs are insufficient for a repo-specific conclusion, return `classification: documentation_conflict_or_gap`.
7. Return bounded conclusion and safest next step.

## Guardrails
- Read-only triage only in v1.
- Separate observation from recommendation.
- Do not upgrade generic Argo/Kubernetes guidance into repo policy when repo docs are unclear.
- If only stale/conflicting docs are available, stop and escalate conflict rather than prescribing remediation.

## Output contract
Return shared output contract from `classification-and-guardrails.md`.
