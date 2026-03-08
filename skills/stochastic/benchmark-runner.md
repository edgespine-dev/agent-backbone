---
name: benchmark-runner
description: execute versioned benchmark suites for quality gates and trend tracking in artifact-based ai pipelines.
---

# benchmark-runner

## Purpose
Run reproducible benchmark evaluations over time for decomposed artifact-based AI pipelines.

## Primary scope
- Execute versioned benchmark datasets.
- Produce gate decisions against defined thresholds.
- Track quality trends across versions.

## Not responsible for
- Pairwise root-cause comparison as primary objective.
- Transformation-based stability testing as primary objective.
- Replacing deterministic contract and invariant checks.

## Canonical references
- `project test policy` (normative)
- `project benchmark specification`
- `project architecture document`
- `skills/references/oracle-types.md`
- `skills/references/deterministic-vs-stochastic.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`

## Inputs
- Versioned benchmark dataset definitions.
- Execution config (model/prompt/pipeline version).
- Benchmark metrics and gate thresholds.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `test_policy.md` (or equivalent)
- benchmark definitions and scoring config
- `architecture.md` (or equivalent)
- optional `component_plan.md` for scoped benchmark runs

## Workflow
1. Freeze benchmark set and run configuration.
2. Execute cases and collect scored outputs.
3. Aggregate metrics by topic and failure class.
4. Compare to baseline and thresholds.
5. Emit gate decision and regression summary.

## Oracle type
- Primary: benchmark
- Secondary: mixed

## Outputs
- Benchmark gate report.
- Trend summary across versions.
- Top regressions and improvements.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `differential-model-tester`: this skill owns absolute/thresholded gate tracking over versioned datasets; differential skill owns variant-vs-variant divergence.
- Near `metamorphic-ai-tester`: this skill uses fixed benchmark sets; metamorphic skill uses transformed-input relation tests.
- Near `semantic-acceptance-evaluator`: semantic skill defines acceptance policy framing; this skill operationalizes dataset-level gate execution.

## Done criteria
- Benchmark dataset and thresholds are versioned.
- Results are reproducible and comparable.
- Gate decision is traceable to benchmark evidence.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
