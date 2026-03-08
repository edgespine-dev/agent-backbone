---
name: test-matrix-designer
description: design test coverage across step type scope oracle and non-functional dimensions.
---

# test-matrix-designer

## Purpose
Build coherent test coverage plans for decomposed artifact-based AI pipelines.

## Primary scope
- Map tests across deterministic/stochastic/hybrid step types.
- Map tests across unit/integration/system/acceptance scopes.
- Assign primary and secondary oracle methods per target.

## Not responsible for
- Executing implementation delivery work.
- Running benchmark/judge/metamorphic infrastructure itself.
- Rewriting architecture decomposition.

## Canonical references
- `project test policy` (normative)
- `project architecture document`
- `project component plan(s)`
- `skills/references/oracle-types.md`
- `skills/references/deterministic-vs-stochastic.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`

## Inputs
- Step classification map.
- Scope requirements and quality goals.
- Available oracle methods and constraints.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `test_policy.md` (or equivalent)
- `architecture.md` (or equivalent)
- `component_plan.md` for covered components
- project test data/fixture strategy document

## Workflow
1. Define matrix axes and required minimum coverage.
2. Assign primary oracle per step type and scope.
3. Assign secondary methods where needed.
4. Identify gaps and redundancy overlaps.
5. Produce prioritized execution order.

## Oracle type
- Primary: mixed
- Secondary: checklist

## Outputs
- Traceable test matrix.
- Prioritized test backlog.
- Coverage-gap and overlap report.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `architecture-planner`: architecture skill defines decomposition; this skill defines coverage against it.
- Near `agent-implementation-runner`: runner executes to matrix gates; this skill designs the gates.
- Near `nonfunctional-evaluator`: this skill allocates non-functional coverage requirements; evaluator executes and analyzes them.

## Done criteria
- Each step has explicit scope and primary oracle.
- Deterministic and stochastic verification are clearly separated.
- Gaps and intentional exclusions are documented.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
