# AGENTS.md Template

Use this as a reusable default for repositories that want a compact, implementation-first agent policy.

## Priority

- Apply these rules by default for all tasks in the repository.
- In new chats, `Follow AGENTS.md.` should be enough to activate them if needed.
- Prefer file changes over chat output when implementation is requested.

## Core rules

- Be concise.
- Do not over-explain unless asked.
- When implementation is requested, modify files instead of pasting code in chat.
- Report only:
  - changed files
  - commands run when relevant
  - result
  - blockers
  - critical assumptions, if any

## Design principles

- KISS before DRY
- explicit > clever
- preserve behavior unless explicitly told otherwise
- extract only when duplication is real and current
- no speculative abstractions
- keep changes small and reviewable

# Workflow

- For multi-step or non-trivial tasks:
  - Write a short sprint plan first.
- Each sprint is a **small, testable feature slice**, not an arbitrary step.
- Each sprint is defined by a test case written first.
- Implement one sprint at a time.
- Do not restate the full plan in chat.
- Read only the files needed to complete the task safely.

## Sprint and testing model

- Sprints are defined along **behavioral or API boundaries**.
- Tests exist to freeze understanding, not to maximize coverage.
- Prefer concrete, behavior-verifying tests.
- Do NOT mock unless explicitly required.

Early-stage work:
- Very low-level or implementation-coupled tests are allowed.
- Such tests may be temporary.

As APIs stabilize:
- Trivial or redundant low-level tests SHOULD be removed.
- Long-lived tests should focus on API contracts, boundaries, and integration behavior.

Obsolete tests are technical debt.
Agents SHOULD propose removal when appropriate.

## Planning model

Prefer a two-layer planning model when the repository uses planning documents:

- Human-authoritative plan:
  `plans/<feature>_PLAN.md`
- Agent working notes:
  `satellite/.notes/<feature>/`

Rules:

- Treat the human plan as source of truth.
- Do not rewrite the authoritative plan by default.
- Use agent working notes for implementation breakdown, test approach, invariants, risks, and open questions.
- If the task is analysis-first, avoid production code changes and keep output in the agent note area until approved.

## Tracking

Example lightweight structure:

```text
satellite/ # agent working notes
└── .notes/
    └── <feature>/
      ├── PLAN
      │   ├── 00_overview.md
      │   ├── 10_implementation_sprint.md  
      │   ├── 20_test_plan.md
      │   ├── 30_risks_and_assumptions.md
      │   └── 99_open_questions.md  
      └── IMPL
          └── <feature>-sprint-XX.md
```

- `PLAN` = scope + constraints + next step
- `IMPL` = what changed + checks
- keep both terse
- update `PLAN` only on scope change and keep it consistent with the human authoritative plan in plans/<feature>_PLAN.md if it exists
- update `IMPL` on every implementation change, even if the plan is unchanged, to keep a running log of what was done and why 

 

## Editing rules

- Change the minimal possible surface area.
- Do not refactor outside scope.
- Do not rename or move files unless required.

## Verification

- Run targeted tests and lint only when relevant.
- Report actual results, not expectations.

## Delegation

- Delegate only isolated analysis tasks.
- Keep delegated outputs minimal.
- Do not paste subagent logs.

## Output format

If a stricter repo format is not defined, use:

- `Done: ...`
- `Blockers: ...` only if any
- `Assumptions: ...` only if critical
