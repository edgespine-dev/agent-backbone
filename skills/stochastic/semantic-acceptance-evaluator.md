---
name: semantic-acceptance-evaluator
description: evaluate policy-level semantic usefulness and handle borderline outcomes for stochastic outputs.
---

# semantic-acceptance-evaluator

## Purpose
Decide whether outputs are useful and acceptable for domain goals in artifact-based AI pipelines.

## Primary scope
- Apply domain acceptance policy to semantic outputs.
- Evaluate practical usefulness and support quality.
- Handle borderline outcomes and calibration feedback.

## Not responsible for
- Implementing judge execution/audit mechanics.
- Replacing deterministic verification in the shell.
- Owning benchmark/differential infrastructure execution.

## Canonical references
- `project test policy` (normative)
- `project acceptance policy`
- `project domain/task success criteria`
- `skills/references/oracle-types.md`
- `skills/references/deterministic-vs-stochastic.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`

## Inputs
- Output candidates with supporting evidence.
- Acceptance policy and hard-fail conditions.
- Borderline-handling rules and calibration targets.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `test_policy.md` (or equivalent)
- acceptance policy document
- domain-specific success criteria
- optional rubric files shared with judge evaluator

## Workflow
1. Validate mandatory structural preconditions.
2. Apply domain acceptance criteria and fail conditions.
3. Classify outcomes as accepted, rejected, or borderline.
4. Capture rationale and uncertainty notes.
5. Produce calibration feedback for policy/rubric refinement.

## Oracle type
- Primary: mixed
- Secondary: judge-based

## Outputs
- Acceptance decision ledger.
- Borderline-case queue with rationale.
- Calibration recommendations.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `judge-based-evaluator`: this skill owns policy-level acceptability and usefulness interpretation; judge skill owns rubric execution, thresholding, auditability, and replayability.
- Near `benchmark-runner`: this skill defines acceptance semantics; benchmark skill applies those semantics at dataset gate level.
- Near `metamorphic-ai-tester`: this skill assesses usefulness; metamorphic skill assesses transformation stability.

## Done criteria
- Acceptance policy is explicit and consistently applied.
- Borderline handling is visible and repeatable.
- Calibration feedback is actionable and tracked.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
