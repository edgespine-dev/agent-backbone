# EdgeSpine Conflict Matrix (v1)

Use this matrix to avoid false certainty when docs disagree or drift.

## Conflict handling rule
When a conflict below is encountered:
- classify as `documentation_conflict_or_gap`
- cite both sources
- avoid presenting inferred mapping as confirmed repo policy
- provide bounded next step to resolve ambiguity

## Known conflicts and drifts
1. Argo access doc drift:
   - `bootstrap/125_argocd_access.md` contains a stale reference to `bootstrap/160_argod_repo_access.md` and inconsistent local access details.
   - `bootstrap/126_argo_github_access.md` is the canonical source for repo access wiring.

2. Layer naming mismatch:
   - Canonical layer model is in `README.md` and `docs/PROJECT_PLACEMENT.md` (`system/infrastructure/auth/web/agents` mapped to `apps/sys|infra|auth|web|agents`).
   - `docs/STORAGE_POLICY.md` still uses legacy namespace terms (`system-*`, `platform-*`, `app-*`).

3. Secrets path vs DB path specificity:
   - `docs/UNS.md` defines generic secret identity mapping:
     `apps/<namespace_path>/` <-> `kv/<overlay>/<namespace_path>/creds`
   - `docs/APP_DB_POLICY.md` defines DB credential contract with app-specific path:
     `<overlay>/<namespace_path>/db/creds` (for DB credentials, not all secrets).

## Out-of-scope docs
`docs/INDEX.md` is a routing index, not a normative policy source by itself.
