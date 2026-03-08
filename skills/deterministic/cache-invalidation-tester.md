---
name: cache-invalidation-tester
description: verify deterministic cache reuse and invalidation correctness for artifact pipeline steps.
---

# cache-invalidation-tester

## Purpose
Ensure cache correctness for cost-efficient, reproducible artifact-based AI pipelines.

## Primary scope
- Validate fingerprint composition and evaluation.
- Validate hit/miss/invalidate transitions.
- Validate stale handling behavior for cached artifacts.

## Not responsible for
- Semantic acceptance quality of stochastic outputs.
- Endpoint contract coverage outside cache behavior.
- Organization-level performance target definition.

## Canonical references
- `project test policy` (normative)
- `project architecture document`
- `project caching/invalidation policy`
- `project artifact contract definitions`
- `skills/references/artifact-pipeline-pattern.md`
- `skills/references/shared-status-vocabulary.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/policier/persistence_invalidation.md`
- `<project>/PLANS/policier/policier_architecture.md`

## Inputs
- Fingerprint definitions by pipeline step.
- Cache read/write behavior and status semantics.
- Mutation vectors for relevant invalidation dimensions.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `architecture.md` (or equivalent)
- `test_policy.md` (or equivalent)
- `component_plan.md` for caching components
- cache contract fixtures and invalidation scenarios

## Workflow
1. Validate baseline miss then expected hit.
2. Mutate one fingerprint dimension at a time.
3. Assert invalidation behavior for each change class.
4. Assert stable reuse for unchanged fingerprints.
5. Validate stale status and fallback behavior.

## Oracle type
- Primary: exact
- Secondary: invariant

## Outputs
- Cache scenario matrix with expected outcomes.
- Regression suite for stale/incorrect reuse defects.
- Fingerprint coverage report.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `db-invariant-checker`: db skill validates durable state integrity; this skill validates cache correctness decisions.
- Near `nonfunctional-evaluator`: this skill verifies correctness of reuse logic; nonfunctional skill evaluates resulting latency/cost impact.
- Near `api-contract-tester`: API skill validates endpoint contracts; this skill validates cache semantics behind those endpoints.

## Done criteria
- Fingerprint dimensions are explicit and tested.
- Invalid cache reuse paths are blocked.
- Safe reuse paths are deterministic and reproducible.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
