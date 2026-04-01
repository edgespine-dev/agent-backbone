# Scripts

`scripts/` contains repository entrypoints.

## Entry points

- `install_codex`
  default Codex installer entrypoint
- `install_claude`
  default Claude installer entrypoint
- `codex_install.sh`
  Codex installer implementation
- `claude_install.sh`
  Claude installer implementation
- `verify/`
  verification entrypoints
- `verify_pilot_edgespine.sh`
  compatibility verification entrypoint
- `migrate/`
  migration helpers

## Rules

- Keep scripts small and explicit.
- Prefer stable entrypoints over ad hoc commands in documentation.
- Do not put policy text in scripts.
- Do not put agent working notes in this directory.

## Relation to the rest of the repository

- `scripts/` executes against `registry/`, `skills/`, and install destinations.
- `policies/` remains the policy authority.
- If script behavior changes, update the relevant README so the documented entrypoint
  remains accurate.
