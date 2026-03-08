---
name: agent-orchestration-planner
description: define agent boundaries dependencies runtime order and contract lock points.
---

# agent-orchestration-planner

## Purpose
Plan reliable multi-agent coordination for decomposed artifact-based AI pipelines.

## Primary scope
- Define agent responsibilities and ownership boundaries.
- Define build/runtime dependency order.
- Define contract lock points that enable safe parallel work.

## Not responsible for
- Running implementation delivery tasks.
- Running semantic evaluation suites.
- Replacing boundary verification execution.

## Canonical references
- `project test policy` (normative)
- `project architecture document`
- `project orchestration/dependency document`
- `project artifact contract definitions`
- `skills/references/shared-status-vocabulary.md`
- `skills/references/artifact-pipeline-pattern.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/policier/agent_orchestration.md`
- `<project>/PLANS/policier/policier_architecture.md`

## Inputs
- Agent/component catalog.
- Upstream/downstream dependency map.
- Shared create/read/ensure response-base conventions.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `agent_orchestration.md` (or equivalent)
- `architecture.md` (or equivalent)
- `test_policy.md` (or equivalent)
- component ownership mapping and contract docs

## Workflow
1. Lock agent ownership and boundaries.
2. Lock shared status and response conventions.
3. Define hard build-order dependencies.
4. Define runtime order and ensure-backfill semantics.
5. Mark parallelization-safe lanes and integration checkpoints.

## Oracle type
- Primary: checklist
- Secondary: invariant

## Outputs
- Agent dependency and ownership matrix.
- Build/runtime orchestration plan.
- Contract lock checklist.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `architecture-planner`: architecture skill defines decomposition shape; this skill defines concrete coordination and order.
- Near `agent-implementation-runner`: this skill plans; runner skill executes and tracks gate progress.
- Near `integration-contract-verifier`: verifier tests realized boundaries; this skill defines expected boundary map.

## Done criteria
- Ownership and dependencies are unambiguous.
- Contract lock points are explicit.
- Runtime flow is testable end-to-end.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
