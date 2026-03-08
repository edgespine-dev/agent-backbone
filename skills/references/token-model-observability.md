# token-model-observability

This reference defines the minimum observability contract for ai-backed steps in decomposed artifact-based pipelines.

## Purpose
Provide traceable answers to:
- which model was used
- when it was used
- why it was selected
- how many tokens were consumed
- what the estimated inference cost was
- whether output came from cache or recomputation

## Observability envelope v1 (required for ai-backed steps)
The following fields are required unless explicitly documented as unavailable in the project contract:

- `run_id`
- `step`
- `trace_id`
- `span_id` (or equivalent step-level trace handle)
- `started_at`
- `ended_at`
- `duration_ms`
- `model_id`
- `model_provider` (if applicable)
- `model_version` (or immutable model fingerprint)
- `selection_reason` (policy/routing reason)
- `prompt_artifact_id` (or equivalent prompt lineage pointer)
- `input_tokens`
- `output_tokens`
- `total_tokens`
- `estimated_cost`
- `currency` (for `estimated_cost`)
- `pricing_source` (rate card/version/source reference)
- `used_cache`
- `cache_decision_reason`

## Recommended run-level aggregation fields
- token/cost totals per run
- token/cost totals per step type
- token/cost totals per model id/version
- cache hit rate by step
- recomputation rate by step

## Explainability requirement
Model and token telemetry should be linkable to lineage/explainability views, not stored as isolated metrics.
For ai-backed steps, `trace_id`, `span_id`, and `prompt_artifact_id` should resolve to persisted lineage artifacts/views.

## Cross-project comparability rule
Emit `estimated_cost`, `currency`, and `pricing_source` together so token/cost telemetry can be compared across projects and environments.

## Gate rule
For ai-backed steps, missing envelope fields should fail quality gates unless explicitly waived by project policy.

## Non-applicability rule
For deterministic non-ai steps, explicitly mark telemetry as `not_applicable` rather than omitting observability fields silently.

## Completeness checklist (do not forget)
- correctness: align with project test policy and contract verification.
- execution safety: align with project ai code safety policy.
- operational readiness: align with project non-functional policy and thresholds.

## Policy anchors
- project test policy (correctness)
- project non-functional policy (operational readiness)
- project ai code safety policy (execution safety)

## Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/testing/nonfunctional_policy.md`
- `<project>/PLANS/testing/ai_code_safety_policy.md`
