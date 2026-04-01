# AGENTS.md

Apply these rules by default for work in this repository.

This repo uses two layers:

- Base reusable agent template: `templates/AGENTS.md`
- EdgeSpine team policy: `policies/edgespine_agent_policy.md`

If the two differ:

- the EdgeSpine team policy wins for this repo
- repository-specific user or maintainer instructions win over both

## Default behavior in this repo

- Be concise.
- Prefer file changes over chat output when implementation is requested.
- Keep changes small and reviewable.
- Use short plans for non-trivial work.
- Treat `plans/` as human-authoritative unless explicitly told otherwise.
- Use `satellite/.notes/` for agent working notes, breakdowns, risks, and open questions.
- Follow the EdgeSpine flow:
  `PLAN -> WRITE TESTS -> REVIEW -> EXECUTE -> REVIEW -> TEST`

## Reporting

Report only what matters:

- changed files
- commands run when relevant
- result
- blockers
- critical assumptions

## Planning surfaces

- `plans/<feature>_PLAN.md` is the human-authoritative plan.
- Agents should not rewrite the authoritative human plan by default.
- Agent decomposition and analysis should go under `satellite/.notes/<feature>/`.
- If asked to analyze before coding, work only in `satellite/.notes/` unless explicitly instructed otherwise.
