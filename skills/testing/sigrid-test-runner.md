---
name: sigrid-test-runner
description: run a minimal sigrid-style test loop with explicit scope, oracle, and pass-fail traceability.
---

# sigrid-test-runner

## Purpose
Run a compact test loop for Sigrid-style evaluation where scope and oracle are explicit and results are auditable.

## Primary scope
- Lock test scope and acceptance target.
- Define oracle and pass/fail threshold.
- Capture reproducible result summary.

## Not responsible for
- Designing full enterprise QA policy.
- Replacing deterministic contract tests.
- Running external services not available in the current environment.

## Workflow
1. Define test scope and expected behavior.
2. Define oracle type and threshold.
3. Execute test run and capture outcomes.
4. Classify result as pass, fail, or insufficient evidence.
5. Output next smallest remediation step on failure.

## Output contract
Return:
- `scope`
- `oracle`
- `threshold`
- `result`
- `evidence`
- `next_smallest_step`
