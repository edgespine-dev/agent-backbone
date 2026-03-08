---
name: code-review-checklist
description: apply manual or semi-manual risk review for contracts invariants and test gaps in ai pipelines.
---

# code-review-checklist

## Purpose
Provide a repeatable review checklist for high-risk changes in decomposed artifact-based AI pipelines.

## Primary scope
- Review contract and invariant safety in change sets.
- Review failure-mode handling and observability readiness.
- Review adequacy of deterministic and stochastic test coverage.

## Not responsible for
- Running automated static tooling as primary mechanism.
- Replacing deterministic contract or invariant tests.
- Acting as benchmark/differential/metamorphic executor.

## Canonical references
- `project test policy` (normative)
- `project architecture document`
- `project orchestration/dependency document`
- `project test matrix`
- `skills/references/deterministic-vs-stochastic.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/policier/policier_architecture.md`
- `<project>/PLANS/policier/agent_orchestration.md`

## Inputs
- Pull request or change diff.
- Contract docs and invariants for affected components.
- Existing test matrix and recent test outcomes.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `test_policy.md` (or equivalent)
- `architecture.md` (or equivalent)
- `agent_orchestration.md` (or equivalent)
- `component_plan.md` for changed components

## Workflow
1. Check contract compatibility and version impact.
2. Check invariant preservation and side-effect safety.
3. Check failure handling and diagnosability.
4. Check test-method correctness per step type.
5. Record findings by severity and ownership.

## Oracle type
- Primary: checklist
- Secondary: mixed

## Outputs
- Severity-ordered review findings.
- Merge-readiness recommendation.
- Follow-up actions for gaps and risks.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `lint-and-static-review`: lint skill runs automatable static gates; this skill performs manual/semi-manual behavioral risk review.
- Near `api-contract-tester`: contract tester validates endpoint behavior; this skill checks whether the change introduces broader risk.
- Near `integration-contract-verifier`: integration verifier executes boundary checks; this skill validates that coverage is sufficient.

## Done criteria
- High-severity findings are resolved or explicitly accepted.
- Test and contract gaps are explicit with owners.
- Review outcome is traceable to concrete risks.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
