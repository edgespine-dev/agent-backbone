# Verify Scripts

`scripts/verify/` contains repository checks for install profiles, registry entries,
and migration compatibility surfaces.

## Current entrypoints

- `team_default_profile.sh`
  verifies the `team-default` profile and installer dry-run output
- `future_mvp.sh`
  verifies the `future-mvp` profile and registry mappings
- `edgespine_migration.sh`
  compatibility entrypoint for EdgeSpine migration checks

## Rules

- Keep checks deterministic.
- Verify real file paths and registry mappings.
- Prefer failing on missing or inconsistent repository state.
- Do not add environment-specific assumptions unless documented explicitly.
