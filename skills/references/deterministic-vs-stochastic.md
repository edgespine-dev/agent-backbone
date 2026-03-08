# deterministic-vs-stochastic

## Model split
- deterministic shell: orchestration, contracts, db interactions, cache/invalidation, lineage structure, status transitions.
- stochastic core: ai extraction, synthesis, ranking, semantic evaluation.
- hybrid step: deterministic wrapper behavior around stochastic model behavior.

## Method implications
- deterministic and hybrid shell behavior should use exact and invariant verification where possible.
- stochastic behavior should use semantic methods such as judge-based, metamorphic, differential, and benchmark evaluation.
- method selection must be explicit per step type and test scope.
- ai-backed steps should emit explicit model and token telemetry for traceability.

## Non-negotiable rule
Do not replace deterministic verification with judge-based evaluation.

## Scope mapping reminder
Each target should be mapped to at least one scope:
- unit
- integration
- system
- acceptance

## Policy anchor
Use the project test policy as normative method-selection guidance.

## Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
