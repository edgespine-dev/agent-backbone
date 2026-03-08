---
name: integration-contract-verifier
description: verify producer-consumer artifact contracts across pipeline step boundaries.
---

# integration-contract-verifier

## Purpose
Prevent integration drift between decomposed pipeline steps in artifact-based AI systems.

## Primary scope
- Validate step boundary producer/consumer compatibility.
- Validate artifact field semantics across integrations.
- Validate dependency propagation and missing-dependency behavior.

## Not responsible for
- Endpoint transport contract conformance.
- Semantic evaluation policy and scoring mechanics.
- Manual code review workflow.

## Canonical references
- `project test policy` (normative)
- `project architecture document`
- `project orchestration/dependency document`
- `project artifact contract definitions`
- `skills/references/artifact-pipeline-pattern.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/policier/agent_orchestration.md`
- `<project>/PLANS/policier/policier_architecture.md`

## Inputs
- Producer and consumer artifact schemas.
- Dependency graph and runtime ordering rules.
- Integration fixtures spanning step boundaries.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `agent_orchestration.md` (or equivalent)
- `architecture.md` (or equivalent)
- `component_plan.md` for producer and consumer components
- artifact boundary fixture set

## Workflow
1. Enumerate active producer/consumer boundaries.
2. Validate required fields and semantic agreements.
3. Validate compatibility under schema/version updates.
4. Validate failure and dependency-missing propagation.
5. Validate ensure behavior that backfills dependencies.

## Oracle type
- Primary: invariant
- Secondary: exact

## Outputs
- Boundary compatibility matrix.
- Drift defect report with owner mapping.
- Regression fixtures for critical boundaries.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `api-contract-tester`: API skill validates endpoint contracts; this skill validates internal step-to-step artifact compatibility.
- Near `artifact-lineage-tester`: this skill validates contract compatibility at boundaries; lineage skill validates full provenance continuity.
- Near `agent-orchestration-planner`: planner defines expected dependency map; this skill verifies implemented boundary behavior.

## Done criteria
- Critical boundaries have explicit passing checks.
- No consumer depends on undocumented producer behavior.
- Dependency propagation behavior is consistent.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
