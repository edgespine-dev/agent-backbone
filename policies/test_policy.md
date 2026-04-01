# Test Policy

This policy exists to help a mixed-experience team use AI assistance without lowering the quality bar.

## Purpose

- Make expected verification explicit before and after AI-assisted changes.
- Prefer small, reproducible checks over vague "it should work" claims.
- Keep tests close to the risk of the change.

## Required baseline

For any non-trivial change, record:

- what changed
- what could break
- what was verified
- what could not be verified locally

When using plan documents:

- treat `plans/<feature>_PLAN.md` as the human-authoritative plan
- keep agent test decomposition and exploratory notes in `satellite/.notes/<feature>/`
- do not silently change the human plan while preparing tests

## Minimum expectations by change type

Documentation-only changes:

- verify links and paths when practical
- avoid changing commands without checking them

Installer, wrapper, or config-generation changes:

- run at least one dry-run or smoke command
- verify the generated target paths or manifest output

Policy or workflow changes:

- verify examples still match the real repo structure
- check that onboarding instructions remain runnable

Domain-skill changes:

- verify the referenced source-of-truth docs and paths still exist
- check any related install profile or verify script

## Evidence standard

Good evidence:

- a command that ran successfully
- a verify script with a clear pass/fail signal
- a small generated artifact inspected against expected output

Weak evidence:

- "looks right"
- "the AI said it should work"
- "it probably exists in the other repo"

## Review rule

If a change adds a new skill or policy, the author should also add one of:

- a profile entry
- a verify script
- a short usage example

That keeps the repo useful to new teammates instead of turning into a prompt dump.
