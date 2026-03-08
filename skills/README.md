# Skills Catalog

This repository is a general reusable skill set optimized for decomposed artifact-based ai pipelines.

It is designed for systems with:
- explicit pipeline steps
- intermediate artifacts
- deterministic shell + stochastic core
- create/read/ensure behavior
- lineage/provenance requirements
- test-first planning and verification
- explicit model and token observability

## Catalog layout
- `deterministic/`: deterministic shell verification skills
- `stochastic/`: semantic and probabilistic evaluation skills
- `orchestration/`: planning and delivery coordination skills
- `references/`: shared catalog-level references and vocabulary

## How to bind the catalog to a project
Use the same skills across projects by providing project-specific documents at runtime.

Recommended bindings:
- `architecture.md` (or equivalent): pipeline decomposition and artifact flow
- `agent_orchestration.md` (or equivalent): dependency map and runtime order
- `test_policy.md` (or equivalent): normative testing policy
- `nonfunctional_policy.md` (or equivalent): operational readiness and cost/latency policy
- `ai_code_safety_policy.md` (or equivalent): execution safety and approval policy
- `component_plan.md` (or equivalent): per-component contracts, invariants, and scope
- contract fixtures, rubric definitions, benchmark specs, and token/cost telemetry schema as needed

## Minimal project documents needed
1. architecture document
2. test policy (normative)
3. orchestration/dependency document (for multi-step systems)
4. component plan(s) for targeted components
5. artifact/API contract fixtures for verification skills
6. model routing + token/cost observability specification

## Observability baseline (v1)
For ai-backed steps, define an explicit envelope with at least:
- traceability: `run_id`, `step`, `trace_id`, `span_id`, `prompt_artifact_id`
- timing: `started_at`, `ended_at`, `duration_ms`
- model identity: `model_id`, `model_provider`, `model_version`, `selection_reason`
- token/cost: `input_tokens`, `output_tokens`, `total_tokens`, `estimated_cost`, `currency`, `pricing_source`
- reuse: `used_cache`, `cache_decision_reason`

For ai-backed steps, `trace_id`, `span_id`, and `prompt_artifact_id` should resolve to persisted lineage artifacts/views.
For cost comparability across projects, emit `estimated_cost`, `currency`, and `pricing_source` together.

For deterministic non-ai steps, use `not_applicable` where telemetry fields do not apply.

## Shared references to use first
- `references/artifact-pipeline-pattern.md`
- `references/deterministic-vs-stochastic.md`
- `references/oracle-types.md`
- `references/shared-status-vocabulary.md`
- `references/token-model-observability.md`

## Optional example binding
The catalog can be bound to Policier documents as an example, but this is optional:
- `<project>/PLANS/policier/policier_architecture.md`
- `<project>/PLANS/policier/agent_orchestration.md`
- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/testing/nonfunctional_policy.md`
- `<project>/PLANS/testing/ai_code_safety_policy.md`
