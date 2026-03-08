---
name: architecture-planner
description: decompose systems into artifact-based deterministic stochastic and hybrid pipeline steps.
---

# architecture-planner

## Purpose
Translate project architecture into a testable artifact pipeline decomposition.

## Primary scope
- Identify pipeline steps and artifact boundaries.
- Classify steps as deterministic, stochastic, or hybrid.
- Identify contract-critical surfaces and risks.

## Not responsible for
- Detailed runtime coordination ownership.
- Implementation execution tracking.
- Running benchmark or judge pipelines directly.

## Canonical references
- `project test policy` (normative)
- `project architecture document`
- `project component plan(s)`
- `skills/references/artifact-pipeline-pattern.md`
- `skills/references/deterministic-vs-stochastic.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/policier/policier_architecture.md`

## Inputs
- Architecture description and scope constraints.
- Existing component plans and interface notes.
- Initial artifact and contract assumptions.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `architecture.md` (or equivalent)
- `component_plan.md` files for key components
- `test_policy.md` (or equivalent)
- optional dependency/orchestration map

## Workflow
1. Decompose end-to-end flow into explicit artifact-producing steps.
2. Classify each step type and determinism expectation.
3. Map contracts and invariants per step.
4. Map recommended test scope per step.
5. Produce risk-prioritized architecture work plan.

## Oracle type
- Primary: checklist
- Secondary: mixed

## Outputs
- Step classification map.
- Contract/invariant requirement map.
- Architecture-driven implementation/testing priorities.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `test-matrix-designer`: architecture skill defines decomposition; matrix skill defines coverage against that decomposition.
- Near `agent-orchestration-planner`: architecture skill defines system shape; orchestration skill defines dependency and runtime order.
- Near `nonfunctional-evaluator`: architecture skill highlights non-functional risk surfaces; evaluator measures outcomes.

## Done criteria
- Decomposition and step classification are explicit.
- Contract-critical boundaries are identified.
- Output is actionable for matrix and orchestration planning.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
