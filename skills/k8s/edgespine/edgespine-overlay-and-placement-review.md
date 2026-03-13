---
name: edgespine-overlay-and-placement-review
description: review app placement and overlay limiting decisions against EdgeSpine repo policy and generator flow.
---

# edgespine-overlay-and-placement-review

## Purpose
Validate whether a change belongs in the right project/layer path and whether overlay-specific behavior is implemented in the correct source files.

## Primary scope
- Placement validation (`sys/infra/auth/web/agents`).
- Overlay allow-list/patch pattern review.
- Generated-vs-source change point guidance.

## Not responsible for
- Writing deployment manifests.
- Executing bootstrap scripts.
- Runtime cluster changes.

## Read first
- `/home/esadmin/agent-backbone/skills/k8s/references/source-of-truth.md`
- `/home/esadmin/agent-backbone/skills/k8s/references/classification-and-guardrails.md`
- `/home/esadmin/bakerlabs-k8s/docs/PROJECT_PLACEMENT.md`
- `/home/esadmin/bakerlabs-k8s/docs/OVERLAY_APP_LIMITING.md`
- `/home/esadmin/bakerlabs-k8s/README.md`

## Workflow
1. Normalize requested layer naming.
2. Check placement against `PROJECT_PLACEMENT` and `README` model.
3. Check overlay logic against `OVERLAY_APP_LIMITING` pattern.
4. Determine whether source config or generated output should be changed.
5. Return verdict with explicit risks.

## Guardrails
- Do not recommend hand-editing generated appset outputs if source templates/config are the real source.
- Do not mix overlay-specific behavior into global templates without explicit policy basis.

## Output contract
Return shared output contract from `classification-and-guardrails.md`.
