# Migration Scripts

`scripts/migrate/` is reserved for migration helpers.

## Current entrypoints

- `../verify_pilot_edgespine.sh`
- `../verify/edgespine_migration.sh`
- install-related wrappers under `../install/`

## Rule

Keep migration helpers here only when they are repository-maintained operational
entrypoints. Do not use this directory for planning notes.
