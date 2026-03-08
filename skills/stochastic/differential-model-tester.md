---
name: differential-model-tester
description: compare model prompt or pipeline variants to detect semantic divergence risks.
---

# differential-model-tester

## Purpose
Detect risky behavior changes when switching variants in decomposed artifact-based AI pipelines.

## Primary scope
- Compare outputs across model/prompt/pipeline variants.
- Quantify divergence and acceptance deltas.
- Localize regressions by scenario.

## Not responsible for
- Owning long-term benchmark gate governance.
- Owning metamorphic transformation libraries.
- Validating endpoint transport contracts.

## Canonical references
- `project test policy` (normative)
- `project variant evaluation plan`
- `project architecture document`
- `skills/references/oracle-types.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`

## Inputs
- Comparison dataset shared across variants.
- Variant definitions and runtime configuration.
- Divergence thresholds and evaluation rubric.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `test_policy.md` (or equivalent)
- variant-change plan or release note
- comparison dataset + rubric files
- `component_plan.md` for affected pipeline steps

## Workflow
1. Freeze dataset and execution conditions.
2. Run all target variants on identical inputs.
3. Compare outputs/scores and calculate deltas.
4. Flag suspicious divergence with examples.
5. Provide release recommendation and mitigation options.

## Oracle type
- Primary: differential
- Secondary: judge-based

## Outputs
- Variant comparison report.
- Divergence summary by scenario.
- Go/no-go recommendation with risk notes.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `benchmark-runner`: differential skill compares alternatives directly; benchmark skill tracks dataset gates and trends over time.
- Near `metamorphic-ai-tester`: differential skill compares variants on same inputs; metamorphic skill compares baseline and transformed-input behavior.
- Near `judge-based-evaluator`: judge skill provides scoring mechanics; this skill uses those signals for comparative analysis.

## Done criteria
- Divergence is quantified and reproducible.
- High-risk deltas are backed by concrete cases.
- Recommendation is tied to explicit criteria.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
