# EdgeSpine cutover log

Date: 2026-03-11
Scope: `bakerlabs-k8s/skills/edgespine` -> `agent-backbone/skills/k8s/edgespine`

## Completed
- Migrated all 6 EdgeSpine skills to canonical markdown under `agent-backbone/skills/k8s/edgespine/`.
- Migrated shared EdgeSpine references to `agent-backbone/skills/k8s/references/`.
- Added registry entries and profile mappings in `registry/skills.yaml` and `registry/profiles/*.yaml`.
- Updated `agent-backbone` installers to include `k8s/edgespine` skills.
- Updated old skill files in `bakerlabs-k8s` to compatibility wrappers with canonical replacement paths.
- Added deprecation warnings to `bakerlabs-k8s` install entrypoints.

## Verify
- `scripts/verify_pilot_edgespine.sh` status: pass (`edgespine migration verify ok`)
- `scripts/codex_install.sh --dry-run` status: pass (all 6 EdgeSpine skills listed)
- `scripts/claude_install.sh --dry-run` status: pass (all 6 EdgeSpine commands listed)
- `bakerlabs-k8s/skills/edgespine/scripts/verify_all.sh` status: pass

## Go/No-Go sign-off
- release_owner_signoff: pending
- domain_owner_signoff: pending

## Notes
- Deletion of old `bakerlabs-k8s` skill paths is deferred to deprecation window end.
- Go/No-Go sign-off is the remaining gate before declaring cutover complete.
