---
name: db-invariant-checker
description: verify persistence invariants and idempotent database behavior for artifact-based ai pipelines.
---

# db-invariant-checker

## Purpose
Protect deterministic persistence integrity in mixed deterministic/stochastic AI systems.

## Primary scope
- Validate schema-level invariants and relational integrity.
- Validate idempotent create/ensure persistence behavior.
- Validate invariant-preserving migration behavior.

## Not responsible for
- Endpoint API contract verification.
- Semantic acceptance scoring for AI outputs.
- Runtime orchestration planning.

## Canonical references
- `project test policy` (normative)
- `project architecture document`
- `project persistence/data-model specification`
- `project artifact contract definitions`
- `skills/references/shared-status-vocabulary.md`
- `skills/references/token-model-observability.md`

### Example project binding (optional)
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/policier/persistence_invalidation.md`
- `<project>/PLANS/policier/policier_architecture.md`

## Inputs
- Schema and migration definitions.
- Table-level and relation-level invariants.
- Persistence fixtures for valid/invalid paths.
- Token and model observability specification for affected AI-backed steps.

### Project binding
- `architecture.md` (or equivalent)
- `component_plan.md` for persistence-owning components
- `test_policy.md` (or equivalent)
- migration files and invariant test fixtures

## Workflow
1. Enumerate invariants per table and relation.
2. Validate required fields, keys, and referential constraints.
3. Validate idempotent write behavior under repeats/retries.
4. Validate transaction behavior under partial failures.
5. Validate read-state consistency for expected statuses.

## Oracle type
- Primary: invariant
- Secondary: exact

## Outputs
- DB invariant assertion suite.
- Invariant violation report with reproducible cases.
- Migration-risk notes for invariant-sensitive changes.
- Observability envelope output for affected steps linking lineage (`run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`) with model identity (`model_id`, `model_provider`, `model_version`) and token/cost fields (`input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`).

## Boundaries and overlaps
- Near `artifact-lineage-tester`: this skill validates persistence invariants; lineage skill validates cross-artifact provenance continuity.
- Near `cache-invalidation-tester`: cache skill validates reuse logic; this skill validates durable data correctness.
- Near `integration-contract-verifier`: integration skill validates boundary compatibility; this skill validates storage integrity.

## Done criteria
- Persistence invariants are explicit and passing.
- Idempotent retries avoid duplicate/corrupt state.
- Migration-impact risks are known and covered.
- AI-backed steps satisfy observability envelope v1 and link traces to prompt lineage (`trace_id`, `span_id`, `prompt_artifact_id`); cost telemetry remains cross-project comparable via `estimated_cost`, `currency`, and `pricing_source`; deterministic non-ai steps explicitly mark telemetry as `not_applicable`.

## Open questions
- None.
