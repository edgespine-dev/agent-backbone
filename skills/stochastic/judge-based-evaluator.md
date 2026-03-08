---
name: judge-based-evaluator
description: execute rubric-threshold judge evaluation with auditability and replayability for stochastic outputs.
---

# judge-based-evaluator

## Purpose
Provide a strict, replayable evaluation engine for stochastic outputs in artifact-based AI pipelines.

## Primary scope
- Run rubric-driven judge evaluations.
- Apply explicit thresholds and decision logic.
- Persist auditable, replayable evaluation records.

## Not responsible for
- Defining domain acceptance policy goals.
- Replacing deterministic shell verification.
- Owning benchmark release decisions by itself.

## Canonical references
- `project test policy` (normative)
- `project judge rubric specification`
- `project acceptance threshold policy`
- `skills/references/oracle-types.md`
- `skills/references/deterministic-vs-stochastic.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`

## Inputs
- Candidate output and required evaluation context.
- Judge rubric, scoring weights, and thresholds.
- Judge prompt template and replay metadata format.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `test_policy.md` (or equivalent)
- judge rubric file(s)
- threshold/governance policy for acceptance
- optional `component_plan.md` for evaluated step

## Workflow
1. Build deterministic judge-input envelope.
2. Execute rubric scoring with explicit criteria.
3. Apply threshold decision logic.
4. Store score, rationale, and replay metadata.
5. Emit structured acceptance signal.

## Oracle type
- Primary: judge-based
- Secondary: invariant

## Outputs
- Per-case judge records.
- Aggregated score/threshold outcomes.
- Replayable audit bundle.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `semantic-acceptance-evaluator`: this skill owns rubric execution, thresholding, and replay/audit mechanics; semantic skill owns policy-level usefulness judgment, borderline handling, and calibration loop.
- Near `benchmark-runner`: benchmark skill governs dataset-level gates; this skill provides judge signals used by those gates.
- Near `api-contract-tester`: this skill cannot replace deterministic contract verification.

## Done criteria
- Rubric and thresholds are explicit and versioned.
- Judge outputs are replayable and auditable.
- Deterministic checks remain separate and intact.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- Should multi-judge ensemble defaults be standardized for high-stakes use cases?
