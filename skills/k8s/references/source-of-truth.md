# EdgeSpine Source of Truth

Use this priority order for all skills:

1. Normative repo policy and architecture docs:
   - `README.md`
   - `docs/PROJECT_PLACEMENT.md`
   - `docs/STORAGE_POLICY.md`
   - `docs/APP_DB_POLICY.md`
   - `docs/UNS.md`
2. Deployment and operations docs:
   - `docs/INDEX.md`
   - `bootstrap/*.md`
   - app runbooks under `apps/*/**/README.md`
3. Repo structure and generation flow:
   - `bootstrap/config/*`
   - `bootstrap/130_apply_proj_app.sh`
   - generated outputs in `apps/*/overlays/*/application-set.yaml`
4. General Kubernetes/Argo best practice.
5. Best-guess inference.

## Conflict handling
- Prefer higher-priority sources.
- If two same-priority sources conflict, report both and mark uncertainty.
- If a referenced document is stale, missing, or internally inconsistent, classify as `documentation_conflict_or_gap` and stop short of confident policy advice.
- Use `/home/esadmin/agent-backbone/skills/k8s/references/conflict-matrix.md` for known repo conflicts before producing conclusions.
- Do not present level 4/5 reasoning as policy.

## Required conflict behavior
When policy cannot be resolved from levels 1-3:
- set `classification: documentation_conflict_or_gap`
- include `uncertainty_and_inference` with:
  - `inference_level`
  - `missing_authoritative_doc`
  - `confidence`
  - `conflicting_sources` (if any)
- provide a bounded `suggested_next_step` to obtain authoritative repo guidance.

## Required uncertainty fields
If the conclusion uses level 4 or 5, include:
- `inference_level: 4|5`
- `missing_authoritative_doc: <path or topic>`
- `confidence: low|medium`
