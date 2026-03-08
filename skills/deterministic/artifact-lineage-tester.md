---
name: artifact-lineage-tester
description: verify lineage and provenance integrity across artifact chains in decomposed ai pipelines.
---

# artifact-lineage-tester

## Purpose
Ensure outputs are traceable to upstream evidence in artifact-based AI pipelines.

## Primary scope
- Validate lineage links between pipeline artifacts.
- Validate provenance completeness for explainability/audit.
- Validate that excluded inputs do not appear downstream.

## Not responsible for
- Endpoint transport contract validation.
- Benchmark or semantic acceptance scoring.
- Full non-functional performance analysis.

## Canonical references
- `project test policy` (normative)
- `project architecture document`
- `project orchestration/dependency document`
- `project artifact contract definitions`
- `skills/references/artifact-pipeline-pattern.md`
- `skills/references/deterministic-vs-stochastic.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/policier/policier_architecture.md`
- `<project>/PLANS/policier/agent_orchestration.md`

## Inputs
- Artifact schema/contracts with lineage fields.
- Expected upstream/downstream step relationships.
- Explainability payload/view expectations.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `architecture.md` (or equivalent)
- `agent_orchestration.md` (or equivalent)
- `component_plan.md` for lineage-producing components
- artifact contract fixtures and lineage examples

## Workflow
1. Build expected lineage graph for selected runs.
2. Validate each downstream artifact has resolvable upstream references.
3. Validate continuity of provenance fields across boundaries.
4. Validate exclusion/invalidation effects on lineage.
5. Validate explainability reconstruction against persisted lineage.

## Oracle type
- Primary: invariant
- Secondary: exact

## Outputs
- Lineage validation report.
- Broken-edge/orphan-artifact defect list.
- Reproducible lineage failure fixtures.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `db-invariant-checker`: db skill validates persistence rules; this skill validates provenance continuity across artifacts.
- Near `integration-contract-verifier`: integration skill validates boundary compatibility; this skill validates end-to-end lineage correctness.
- Near `nonfunctional-evaluator`: nonfunctional skill may consume lineage quality metrics but does not own lineage correctness tests.

## Done criteria
- Required outputs can be traced to upstream artifacts.
- No unresolved lineage break remains in passing runs.
- Explainability views align with persisted provenance.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
