---
name: edgespine-runtime-debug-readonly
description: perform read-only runtime triage for EdgeSpine workloads using repo runbooks and policy docs.
---

# edgespine-runtime-debug-readonly

## Purpose
Provide bounded, read-only runtime debugging guidance for workloads in this repo without proposing risky execution flows.

## Primary scope
- Runtime symptom classification.
- Read-only check sequencing.
- Documentation-driven probable-cause analysis.

## Not responsible for
- Applying fixes.
- Restarting workloads.
- Deploy/rollback operations.

## Read first
- `/home/esadmin/agent-backbone/skills/k8s/references/source-of-truth.md`
- `/home/esadmin/agent-backbone/skills/k8s/references/classification-and-guardrails.md`
- `/home/esadmin/agent-backbone/skills/k8s/references/conflict-matrix.md`
- `/home/esadmin/bakerlabs-k8s/docs/INDEX.md`
- app runbooks relevant to target workload under `/home/esadmin/bakerlabs-k8s/apps/`

## Workflow
1. Classify as `runtime_debug_problem`.
2. Identify minimal read-only checks from authoritative docs.
3. Separate verified observations from inferred hypotheses.
4. If runbook coverage is missing or docs conflict, return `classification: documentation_conflict_or_gap`.
5. Recommend safest next checks or handoff target.
6. Declare uncertainty when runbook coverage is missing.

## Guardrails
- Read-only only.
- No destructive or privileged remediation steps.
- No implied policy conclusions without cited docs.
- Do not present generic Kubernetes troubleshooting as repo policy when repo-specific docs are absent.
- Stop at bounded triage when documentation cannot support repo-specific guidance.

## Output contract
Return shared output contract from `classification-and-guardrails.md`.
