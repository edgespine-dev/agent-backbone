---
name: agent-implementation-runner
description: run contract-first implementation loops from locked tests to green pipeline gates.
---

# agent-implementation-runner

## Purpose
Operationalize test-first delivery for decomposed artifact-based AI pipelines across projects.

## Primary scope
- Enforce phase order: contracts/tests first, implementation second.
- Track readiness gates across component/integration/system/acceptance scopes.
- Coordinate incremental rollout while preserving contract stability.

## Not responsible for
- Defining canonical architecture decomposition.
- Designing oracle taxonomy from scratch.
- Substituting judge-only acceptance for deterministic shell checks.

## Canonical references
- `project test policy` (normative)
- `project architecture document`
- `project orchestration/dependency document`
- `project test harness specification`
- `skills/references/shared-status-vocabulary.md`
- `skills/references/artifact-pipeline-pattern.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/policier/policier_architecture.md`
- `<project>/PLANS/policier/agent_orchestration.md`
- `<project>/PLANS/policier/test_harness.md`

## Inputs
- Locked contract definitions and test fixtures.
- Dependency-ordered implementation plan.
- Gate criteria and pass/fail thresholds.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `test_policy.md` (or equivalent)
- `architecture.md` (or equivalent)
- `agent_orchestration.md` (or equivalent)
- `component_plan.md` for each target component
- test harness docs/configuration

## Workflow
1. Confirm contract and fixture lock state.
2. Execute implementation in dependency order.
3. Run gate suites after each increment.
4. Track deviations and remediation actions.
5. Report readiness by scope and component.

## Oracle type
- Primary: checklist
- Secondary: mixed

## Outputs
- Delivery gate status by component and scope.
- Deviation and remediation log.
- Implementation-readiness summary.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `agent-orchestration-planner`: planner defines dependency model; this skill executes delivery against that model.
- Near `test-matrix-designer`: matrix skill defines what coverage is required; this skill tracks implementation until those gates pass.
- Near `architecture-planner`: architecture skill defines decomposition; this skill drives execution through gates.

## Done criteria
- Contract-first policy is respected.
- Required gates are green at defined scope.
- Deviations are explicit and resolved or accepted by policy.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
