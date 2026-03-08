# oracle-types

## Oracle labels used by this catalog
- `exact`: deterministic equality checks for contracts, schemas, statuses, and deterministic side effects.
- `invariant`: checks of properties that must always hold.
- `metamorphic`: relation checks under controlled input transformations.
- `differential`: comparative checks between variants.
- `judge-based`: rubric-driven semantic scoring with explicit thresholds.
- `benchmark`: dataset-level scoring and release gates.
- `checklist`: manual or semi-manual structured review.
- `mixed`: explicit composition of multiple methods.

## Selection guidance
- choose oracle type based on step type (deterministic/stochastic/hybrid) and scope (unit/integration/system/acceptance).
- always keep deterministic shell checks explicit.
- use judge-based oracles as evaluative signals, not transport/persistence contract substitutes.

## Policy anchor
Treat the project test policy as normative for oracle selection and escalation rules.

## Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
