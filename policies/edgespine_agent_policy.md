# EdgeSpine Agent Policy

This policy adapts the general agent template to how the EdgeSpine team wants to work.

It is intentionally entry-level, explicit, and practical.

## Core workflow

Follow this default order for non-trivial work:

`PLAN -> WRITE TESTS -> REVIEW -> EXECUTE -> REVIEW -> TEST`

Interpretation:

1. `PLAN`
   Write a short plan with scope, constraints, and next step.
2. `WRITE TESTS`
   Define the checks first when practical.
3. `REVIEW`
   Review the plan and tests before implementation.
4. `EXECUTE`
   Make the smallest workable change.
5. `REVIEW`
   Review the actual implementation for correctness and simplicity.
6. `TEST`
   Run the relevant checks and report real results.

## Planning ownership

Use a two-layer planning model by default:

- `plans/<feature>_PLAN.md`
  Human-authoritative plan.
- `satellite/.notes/<feature>/`
  Agent-owned working notes.

Rules:

- The human plan is the source of truth.
- The agent should not rewrite the authoritative plan by default.
- The agent may propose changes to the human plan, but should keep its own decomposition separate unless explicitly told to edit the authoritative plan.
- Analysis-first tasks should stay in `satellite/.notes/` and should not modify production code.

Recommended satellite structure:

```text
satellite/.notes/<feature>/
├── 00_overview.md
├── 10_implementation_steps.md
├── 20_test_plan.md
├── 30_risks_and_assumptions.md
└── 99_open_questions.md
```

## Design principles

- KISS > DRY
- explicit > clever
- small testable functions over large smart ones
- prefer half-page functions when reasonable
- no speculative abstractions
- preserve existing behavior unless change is intended

## Testing principles

- Prefer real tests over fake confidence.
- Do not mock systems we did not write ourselves if a small real test setup is practical.
- If we depend on Postgres, prefer a small real Postgres with a little data over a fake repository mock.
- Use the smallest realistic dataset that still exercises the behavior.
- Keep tests easy to run and easy to understand.

## Review principles

- Review before code and after code.
- Review for simplicity, correctness, and testability.
- Flag unnecessary abstraction early.
- If a function is hard to test, treat that as a design smell.

## Planning principles

- Plans should be short.
- Prefer a few concrete steps over long prose.
- Record constraints and risks only when they affect the implementation.
- Update the plan only when scope changes.
- Keep agent notes separate from the human-authoritative plan.
- Put implementation breakdown, files to change, invariants, test approach, and open questions in the satellite notes.
- If a human acceptance checkpoint is needed, stop after updating the satellite notes and surface blockers or questions instead of guessing.

## Editing principles

- Change the smallest safe surface area.
- Do not refactor unrelated code.
- Do not rename or move files unless there is a real reason.

## Reporting

Keep reports compact and factual:

- changed files
- commands run when relevant
- result: pass/fail
- blockers
- critical assumptions

## Intended use

Use this policy when:

- onboarding less experienced teammates
- setting a default way of working across EdgeSpine projects
- curating agent behavior that should stay consistent across repos
