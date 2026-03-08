---
name: metamorphic-ai-tester
description: test stochastic stability using transformation-based relations instead of exact outputs.
---

# metamorphic-ai-tester

## Purpose
Evaluate stochastic robustness through relation-based testing in artifact-based AI pipelines.

## Primary scope
- Define metamorphic transformations and expected relations.
- Run baseline-versus-transformed comparisons.
- Identify transformation-sensitive regressions.

## Not responsible for
- Dataset trend gate ownership.
- Pairwise variant release comparisons as primary mode.
- Endpoint/database deterministic contract checks.

## Canonical references
- `project test policy` (normative)
- `project metamorphic test specification`
- `project architecture document`
- `skills/references/oracle-types.md`
- `skills/references/deterministic-vs-stochastic.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/testing/ai_pipeline_testing_overview.md`

## Inputs
- Baseline test cases and transformation catalog.
- Relation expectations and acceptance thresholds.
- Output normalization rules when needed.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `test_policy.md` (or equivalent)
- metamorphic relation spec files
- `architecture.md` (or equivalent)
- optional `component_plan.md` for targeted stochastic step

## Workflow
1. Select transformations tied to concrete failure hypotheses.
2. Run baseline and transformed cases.
3. Check relation adherence and stability.
4. Record violations with transformation metadata.
5. Promote stable high-value relations to regression suites.

## Oracle type
- Primary: metamorphic
- Secondary: judge-based

## Outputs
- Relation stability report.
- Transformation-based regression cases.
- Prioritized metamorphic test backlog.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `benchmark-runner`: metamorphic skill validates relation stability under transformation; benchmark skill validates fixed dataset gates/trends.
- Near `differential-model-tester`: metamorphic skill compares input transformations; differential skill compares system variants.
- Near `semantic-acceptance-evaluator`: semantic skill evaluates usefulness policy; metamorphic skill evaluates stability relations.

## Done criteria
- Key transformations and relations are explicit.
- Stability thresholds are defined.
- Violations are reproducible from stored cases.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
