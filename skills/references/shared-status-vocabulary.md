# shared-status-vocabulary

## Common status vocabulary
- create/ensure status: `completed`, `failed`, `timed_out`, `partial`
- read status: `available`, `not_found`, `stale`

## Common response-base fields
- `run_id`
- `step`
- `status`
- `validity`
- `warnings`
- `errors`

## AI telemetry extension fields
Use these fields for ai-backed steps. For deterministic non-ai steps, mark as `not_applicable`.

- `trace_id`
- `span_id` (or equivalent)
- `started_at`
- `ended_at`
- `duration_ms`
- `model_id`
- `model_provider` (if applicable)
- `model_version` (or immutable model fingerprint)
- `selection_reason` (routing/policy reason)
- `prompt_artifact_id` (or equivalent prompt lineage pointer)
- `input_tokens`
- `output_tokens`
- `total_tokens`
- `estimated_cost`
- `currency` (for `estimated_cost`)
- `pricing_source` (rate card/version/source reference)
- `used_cache`
- `cache_decision_reason`

## Usage guidance
- treat this as a reusable baseline vocabulary for artifact pipelines.
- if a project extends statuses/fields, document additions explicitly in project contracts.
- do not silently redefine baseline semantics across components.
- for ai-backed steps, treat missing telemetry fields as a gate failure unless policy-waived.
- for ai-backed steps, `trace_id`, `span_id`, and `prompt_artifact_id` should resolve to persisted lineage artifacts/views.
- emit `estimated_cost`, `currency`, and `pricing_source` together to keep cost telemetry comparable across projects.

## Policy anchor
Use project test policy and project contract docs as normative authority for final status semantics.

## Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/policier/policier_architecture.md`
