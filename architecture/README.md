# Architecture Notes

`architecture/` stores repository architecture records and migration history.

## Rules

- Use this directory for durable repository context.
- Do not use it for transient agent notes.
- Do not treat it as authoritative workflow policy when `policies/` says otherwise.

## Current use

- `migration/`
  migration records

## Boundary

If the material changes implementation sequencing for this repository, capture that in
`PLANS/`.
If the material is temporary analysis, keep it in `satellite/.notes/`.
