# EdgeSpine Classification and Guardrails

## Shared problem classes
- `placement_problem`
- `overlay_problem`
- `generated_vs_source_problem`
- `secret_wiring_problem`
- `db_wiring_problem`
- `storage_stateful_problem`
- `argo_gitops_sync_problem`
- `runtime_debug_problem`
- `documentation_conflict_or_gap`

## Layer normalization contract
Normalize all layer labels to canonical repo model:
- `system -> apps/sys/*`
- `infrastructure -> apps/infra/*`
- `auth -> apps/auth/*`
- `web -> apps/web/*`
- `agents -> apps/agents/*`

Legacy label handling:
- If input uses legacy labels (`platform`, `app`), do not present auto-mapping as confirmed policy.
- Attempt tentative mapping only via `README.md` + `docs/PROJECT_PLACEMENT.md` and label it as inference.
- If mapping remains ambiguous or sources conflict, set `classification: documentation_conflict_or_gap`.

## Shared output contract
Every skill output must include:
- `classification`
- `relevant_documents_consulted`
- `conclusion`
- `recommended_change_location`
- `guardrails_and_risks`
- `uncertainty_and_inference`
- `suggested_next_step`

## Guardrails
- Do not edit generated outputs when source template/config is the correct change point.
- Do not propose plaintext secrets in Git.
- Do not recommend shared admin/db credentials when dedicated app creds are policy.
- Do not recommend `hostPath` unless explicit documented exception exists.
- Separate `observation` from `recommendation` from `execution`.
- Runtime debug is read-only in v1.
- Avoid risky deploy/rollback flows unless explicitly documented and safe.
- If repo docs are stale/missing/conflicting, stop with `documentation_conflict_or_gap` instead of guessing.
