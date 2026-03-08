---
name: nonfunctional-evaluator
description: evaluate latency cost robustness explainability and reproducibility for artifact pipelines.
---

# nonfunctional-evaluator

## Purpose
Evaluate cross-cutting production readiness in decomposed artifact-based AI pipelines.

## Primary scope
- Evaluate latency, cost, robustness, explainability, and reproducibility.
- Identify bottlenecks and instability hotspots.
- Provide non-functional release-risk assessment.

## Not responsible for
- Endpoint-level contract correctness.
- Semantic acceptance policy ownership.
- Replacing deterministic or stochastic functional test suites.

## Canonical references
- `project test policy` (normative)
- `project non-functional requirements`
- `project architecture document`
- `skills/references/artifact-pipeline-pattern.md`
- `skills/references/deterministic-vs-stochastic.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/policier/policier_architecture.md`

## Inputs
- Telemetry/traces from representative workloads.
- Non-functional targets and threshold definitions.
- Failure-injection or perturbation scenarios.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `test_policy.md` (or equivalent)
- non-functional requirement document
- `architecture.md` (or equivalent)
- observability/tracing docs and sample runs

## Workflow
1. Define measurable targets and thresholds.
2. Execute representative workloads.
3. Evaluate robustness under perturbation/failure cases.
4. Evaluate explainability and reproducibility quality.
5. Report risks and prioritized remediation actions.

## Oracle type
- Primary: mixed
- Secondary: benchmark

## Outputs
- Non-functional scorecard.
- Bottleneck and risk report.
- Readiness recommendation.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `benchmark-runner`: benchmark skill handles dataset quality gates; this skill handles cross-cutting non-functional behavior.
- Near `cache-invalidation-tester`: cache skill verifies cache correctness; this skill evaluates resulting performance/cost impact.
- Near `test-matrix-designer`: matrix skill allocates non-functional coverage slots; this skill executes and interprets outcomes.

## Done criteria
- Non-functional targets and outcomes are explicit.
- Regressions are tied to reproducible scenarios.
- Release-risk posture is clear and actionable.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
