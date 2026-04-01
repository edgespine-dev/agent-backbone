# Skills Catalog

`skills/` contains the canonical Markdown source for shared skills and their reference
material.

## Layout

- `deterministic/`
  Deterministic checks and review skills.
- `stochastic/`
  Evaluation skills that depend on semantic judgment or comparison.
- `orchestration/`
  Planning and coordination skills.
- `testing/`
  Test runner skills.
- `iot/`
  Embedded and device-specific skills.
- `k8s/`
  Kubernetes and EdgeSpine domain skills.
- `references/`
  Shared reference material used by multiple skills.

## Rules

- Files in this directory are canonical skill content.
- Skills may reference repository policy and reference documents.
- Skills should not redefine repository policy.
- Skills should not be used as a substitute for a consuming repository's plan.

## Binding to a consuming repository

This repository provides reusable skill content. A consuming repository must still
provide its own:

- architecture document
- plan or scoped implementation document
- testing policy binding
- nonfunctional policy binding
- safety or approval policy binding
- contract fixtures or comparable test artifacts when a skill depends on them

## References

Read these first when working across multiple skills:

- `references/artifact-pipeline-pattern.md`
- `references/deterministic-vs-stochastic.md`
- `references/oracle-types.md`
- `references/shared-status-vocabulary.md`
- `references/token-model-observability.md`

## Installation

Install skills through the entrypoints in `scripts/`, not by copying files manually.

```bash
./scripts/install_codex
./scripts/install_claude
```

Use `--list-profiles` to inspect install sets.
