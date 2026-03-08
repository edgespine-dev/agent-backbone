---
name: lint-and-static-review
description: run automated static quality gates for code supporting decomposed artifact-based ai pipelines.
---

# lint-and-static-review

## Purpose
Provide fast, automatable deterministic quality gates before deeper runtime testing.

## Primary scope
- Run lint, type checks, and static analyzers.
- Classify blocking versus advisory findings.
- Validate suppression hygiene and rule scope.

## Not responsible for
- Manual architecture and risk review.
- Runtime integration/system behavior validation.
- Semantic acceptance evaluation for stochastic outputs.

## Canonical references
- `project test policy` (normative)
- `project coding standards and static-tool configuration`
- `skills/references/deterministic-vs-stochastic.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`

## Inputs
- Static tool configuration and rule sets.
- Target file set or component scope.
- Suppression baselines and exception policy.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `test_policy.md` (or equivalent)
- project lint/type/static config files
- `component_plan.md` for affected components

## Workflow
1. Execute configured static gates in project order.
2. Normalize findings by severity and ownership.
3. Validate suppressions for scope and rationale.
4. Highlight minimal safe remediation path.
5. Publish static gate status.

## Oracle type
- Primary: exact
- Secondary: checklist

## Outputs
- Static findings report.
- Blocking/advisory gate summary.
- Suggested minimal fix set.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `code-review-checklist`: this skill is automated static gating; checklist skill is manual/semi-manual behavioral review.
- Near `api-contract-tester`: this skill does not verify runtime contract behavior.
- Near `integration-contract-verifier`: this skill does not verify runtime boundary compatibility.

## Done criteria
- Blocking static gates pass or have explicit waivers.
- Suppressions are scoped and justified.
- No new critical static defects are introduced.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
