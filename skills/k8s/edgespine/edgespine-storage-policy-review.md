---
name: edgespine-storage-policy-review
description: review stateful workload storage design against EdgeSpine deterministic storage policy.
---

# edgespine-storage-policy-review

## Purpose
Assess whether stateful workload design follows repo storage policy for deterministic, auditable, and secure storage behavior.

## Primary scope
- PVC/volume convention checks.
- Writable path discipline checks.
- `hostPath` and security baseline checks.

## Not responsible for
- Capacity planning execution.
- Backup implementation.
- Runtime remediation.

## Read first
- `/home/esadmin/agent-backbone/skills/k8s/references/source-of-truth.md`
- `/home/esadmin/agent-backbone/skills/k8s/references/classification-and-guardrails.md`
- `/home/esadmin/agent-backbone/skills/k8s/references/conflict-matrix.md`
- `/home/esadmin/bakerlabs-k8s/README.md`
- `/home/esadmin/bakerlabs-k8s/docs/PROJECT_PLACEMENT.md`
- `/home/esadmin/bakerlabs-k8s/docs/STORAGE_POLICY.md`

## Workflow
1. Classify issue as `storage_stateful_problem`.
2. Compare manifests against storage naming and mount conventions.
3. Verify no unapproved `hostPath` and no secrets in writable data volumes.
4. Check for naming-model conflicts (canonical layer model vs legacy terms in storage docs).
5. If naming conflict affects recommendation, return `classification: documentation_conflict_or_gap`.
6. Return policy compliance verdict and correct change location.
7. Mark missing policy context explicitly.

## Guardrails
- Do not recommend `hostPath` without explicit documented exception.
- Keep deterministic naming and explicit writable mount guidance.

## Output contract
Return shared output contract from `classification-and-guardrails.md`.
