# Registry

`registry/` defines what can be installed from this repository.

## Files

- `skills.yaml`
  canonical skill registry
- `profiles/*.yaml`
  named install profiles

## Invariants

- `skills.yaml` is the source of truth for installable skills.
- Every profile entry must resolve to a `canonical_id` in `skills.yaml`.
- Every `repo_path` must point to a file that exists in this repository.
- Profiles group existing skills. They do not redefine skill content.

## Responsibilities

- Add or remove installable skills by updating `skills.yaml`.
- Change profile membership by editing the relevant file in `profiles/`.
- Do not place policy or plan content in this directory.

## Verification

Use `scripts/verify/` to check registry and profile consistency.
