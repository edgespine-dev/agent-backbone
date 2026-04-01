# Nonfunctional Policy

This repo should optimize for team usefulness, not catalog size.

## Priorities

1. Clarity for inexperienced teammates.
2. Repeatable setup across machines.
3. Minimal environment-specific assumptions.
4. Small, auditable install and verify steps.

## Quality bar

A change is stronger when it:

- reduces setup friction
- makes recommended usage more obvious
- removes hidden machine-specific assumptions
- adds lightweight verification

A change is weaker when it:

- adds more generic content without improving adoption
- introduces hard-coded home-directory paths without fallback behavior
- makes the install surface broader but the recommended path less clear

## Preferred defaults

- curated profiles over install-everything
- explicit team recommendations over implicit conventions
- smoke tests over hand-wavy claims
- domain-specific guidance over generic AI methodology
