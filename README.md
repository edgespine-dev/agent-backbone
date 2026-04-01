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

Re-run install after changes or `git pull` in `agent-backbone`.

## Using In Another Repo

1. Update or pull `agent-backbone`.
2. Re-run the install command for your runtime.
3. Add a minimal local `AGENTS.md` to the other repo.
4. Keep repo-specific plan locations and constraints in that local file.

Global install provides shared skills.
Each repo still needs its own local `AGENTS.md`.
The local repository policy takes precedence.
Use `agent-backbone` as the shared baseline.

## Minimal Local AGENTS.md

The local file should state:

- that the repo follows the shared `agent-backbone` baseline
- the repo's human-authoritative plan location
- the repo's agent working-note location
- any repo-specific constraints or overrides

Use a short repo-local binding file:

```md
# AGENTS.md

This repository follows the shared `agent-backbone` policy baseline.

## Planning surfaces

- `PLANS/<feature>_PLAN.md` is the human-authoritative plan.
- `satellite/.notes/<feature>/` is the agent working surface.
- Agents should not rewrite the authoritative plan by default.
```

Replace the paths if the consuming repository uses different plan locations.

Suggested setup prompt for a new repo:

```text
Create a minimal AGENTS.md for this repository that binds it to the shared agent-backbone baseline. Keep repo-specific rules and paths in the local file. Treat the local AGENTS.md as primary and agent-backbone as the fallback baseline. For this setup task, only change Markdown.
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
