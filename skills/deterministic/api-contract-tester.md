---
name: api-contract-tester
description: validate endpoint contracts and shared create-read-ensure response base for artifact pipelines.
---

# api-contract-tester

## Purpose
Verify deterministic API behavior for decomposed artifact-based AI pipelines, without coupling to a single project.

## Primary scope
- Validate endpoint contracts for `create`, `read`, and `ensure` operations.
- Validate shared response-base fields and status behavior.
- Validate deterministic error payload structure.

## Not responsible for
- Cross-step producer/consumer artifact compatibility.
- Semantic quality judgment for stochastic AI outputs.
- Manual architecture risk review.

## Canonical references
- `project test policy` (normative)
- `project architecture document`
- `project orchestration/dependency document`
- `project api contract specification`
- `skills/references/artifact-pipeline-pattern.md`
- `skills/references/shared-status-vocabulary.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/policier/policier_architecture.md`
- `<project>/PLANS/policier/agent_orchestration.md`

## Inputs
- Endpoint definitions and transport-level contracts.
- JSON fixtures for request and expected response.
- Status and error vocabulary.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `test_policy.md` (or equivalent)
- `architecture.md` (or equivalent)
- `agent_orchestration.md` (or equivalent)
- `component_plan.md` for the target component
- contract fixture files used by API tests

## Workflow
1. Map endpoints to owning pipeline steps.
2. Validate request schema, response schema, and status codes.
3. Validate shared response-base fields for each endpoint family.
4. Validate idempotency and retry behavior for deterministic paths.
5. Validate negative/error paths and machine-readable error payloads.

## Oracle type
- Primary: exact
- Secondary: invariant

## Outputs
- Endpoint contract test suite.
- Request/response fixture set.
- Contract defect report with endpoint ownership mapping.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `integration-contract-verifier`: this skill owns endpoint contracts; integration skill owns step-to-step artifact boundary compatibility.
- Near `code-review-checklist`: this skill executes deterministic contract checks; checklist skill evaluates broader change risk.
- Near `judge-based-evaluator`: this skill never substitutes deterministic API verification with judge-based evaluation.

## Done criteria
- Target API endpoints pass deterministic contract checks.
- Shared response base is consistently enforced.
- No undocumented mandatory response dependencies remain.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
