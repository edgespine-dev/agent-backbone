# Agent Backbone

Shared repository for team-owned agent policy, skill content, install metadata, and
verification scripts.

## Scope

Contains:

- canonical skill Markdown under `skills/`
- install registry data under `registry/`
- team policy documents under `policies/`
- installer and verification scripts under `scripts/`
- human-authored repository plans under `PLANS/`
- migration and historical notes under `architecture/`
- agent working notes under `satellite/.notes/`

Does not contain:

- project-specific production code
- project-specific implementation plans
- duplicate generic material without a repository-specific reason

## Repository layout

- `skills/`
  canonical skill content and shared references
- `registry/`
  skill registry and install profiles
- `policies/`
  normative team policy
- `scripts/`
  installation and verification entrypoints
- `PLANS/`
  human-authored plans for this repository
- `architecture/`
  migration records and architecture notes
- `satellite/.notes/`
  agent working notes for this repository

## Installation

```bash
./scripts/install_codex
./scripts/install_claude
```

Default profile: `team-default`

List profiles:

```bash
./scripts/install_codex --list-profiles
./scripts/install_claude --list-profiles
```

## Reading order

Read these first:

- `AGENTS.md`
- `policies/test_policy.md`
- `policies/nonfunctional_policy.md`
- `policies/ai_code_safety_policy.md`
- `skills/README.md`
- `registry/README.md`
- `scripts/README.md`

## Path conventions

Policy examples may use `plans/` generically. In this repository the directory is
`PLANS/`.

`PLANS/` is for human-authored repository planning material.
`satellite/.notes/` is for agent working notes.
`skills/`, `registry/`, `policies/`, and `scripts/` are production repository
surfaces and should only change when the task requires it.
