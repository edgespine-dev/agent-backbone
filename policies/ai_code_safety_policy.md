# AI Code Safety Policy

AI assistance is allowed in this repo, but the human team remains responsible for the result.

## Required behavior

- Treat generated content as draft until reviewed.
- Prefer project-specific facts over generic model confidence.
- Mark assumptions when repo context is missing.
- Do not claim tests ran if they did not run.

## Required guardrails

- Do not add secrets, tokens, or machine-local credentials.
- Do not hard-code paths to external repos unless explicitly required and documented.
- Do not depend on external state for core verification when a local smoke test is possible.
- Do not add generic skills just because they sound useful.

## Curating external skills

Before adding an external or copied skill, answer:

- Why is this better than the built-in model behavior?
- What team problem does it solve?
- When should a teammate use it?
- What are the failure modes or misuse risks?

If those answers are weak, do not add the skill yet.
