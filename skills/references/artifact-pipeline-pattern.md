# artifact-pipeline-pattern

This catalog is a general reusable skill set optimized for decomposed artifact-based ai pipelines.

## Core model
1. input
2. intermediate artifacts
3. deterministic and stochastic transformations
4. final outputs
5. explainability and lineage views

## Architectural assumptions
- pipeline steps are explicit and decomposed
- artifact contracts are explicit
- create/read/ensure behavior is explicit
- lineage/provenance is testable
- deterministic shell and stochastic core are treated differently

## Primary verification targets
- endpoint and artifact contracts
- producer/consumer boundary compatibility
- lineage continuity
- cache validity and invalidation behavior
- semantic acceptability for stochastic outputs
- non-functional behavior (latency, cost, robustness, reproducibility)
- model and token observability linked to explainability

## Runtime project binding expectations
At runtime, skills should be bound to project documents such as:
- `architecture.md` (or equivalent)
- `agent_orchestration.md` (or equivalent)
- `test_policy.md` (or equivalent)
- `component_plan.md` (or equivalent)
- contract fixtures and benchmark/rubric definitions
- model routing policy and token/cost telemetry schema (or equivalent)

## Example project binding (optional)
- `<project>/PLANS/policier/policier_architecture.md`
- `<project>/PLANS/policier/agent_orchestration.md`
- `<project>/PLANS/testing/test_policy.md`
