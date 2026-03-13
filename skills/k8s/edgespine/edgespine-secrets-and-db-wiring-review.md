---
name: edgespine-secrets-and-db-wiring-review
description: review EdgeSpine secret, Bao, ExternalSecret, UNS and app-db wiring decisions against repo policy.
---

# edgespine-secrets-and-db-wiring-review

## Purpose
Validate secrets and DB wiring decisions for compliance with UNS, Bao/ExternalSecret flow, and app-specific DB credential policy.

## Primary scope
- Secret path and key contract checks.
- ExternalSecret and runtime env wiring checks.
- Dedicated-credential policy checks.

## Not responsible for
- Creating credentials.
- Rotating secrets.
- Applying runtime changes.

## Read first
- `/home/esadmin/agent-backbone/skills/k8s/references/source-of-truth.md`
- `/home/esadmin/agent-backbone/skills/k8s/references/classification-and-guardrails.md`
- `/home/esadmin/agent-backbone/skills/k8s/references/conflict-matrix.md`
- `/home/esadmin/bakerlabs-k8s/docs/APP_DB_POLICY.md`
- `/home/esadmin/bakerlabs-k8s/docs/UNS.md`
- `/home/esadmin/bakerlabs-k8s/apps/auth/keystore/docs/bootstrap.md`
- `/home/esadmin/bakerlabs-k8s/apps/auth/keystore/docs/maintenance.md`

## Workflow
1. Classify issue as `secret_wiring_problem` or `db_wiring_problem`.
2. For generic secrets, validate UNS identity mapping:
   - `apps/<namespace_path>` <-> `kv/<overlay>/<namespace_path>/creds`.
3. For DB credentials, validate DB-specific contract from `docs/APP_DB_POLICY.md`:
   - `kv/<overlay>/<namespace_path>/db/creds` and app-specific `<APP>_DB_*` key contract.
4. Never treat one app example as a universal DB path without explicit policy support.
5. If app-specific DB contract is missing or conflicts with UNS interpretation, return `classification: documentation_conflict_or_gap`.
6. Flag policy violations and safest change location.
7. Mark uncertainty for missing contract details.

## Guardrails
- Never propose plaintext secrets in Git.
- Never recommend shared admin credentials when dedicated app credentials are policy.
- Do not collapse DB-specific credential paths into generic `/creds` rules.
- If policy evidence is insufficient for a target app, stop with conflict/gap classification.

## Output contract
Return shared output contract from `classification-and-guardrails.md`.
