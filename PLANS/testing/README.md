# Testing Policy Binding

This repository keeps shared policy documents under `policies/`.

## Use

Bind a consuming repository to its own testing-policy location, for example:

- `<project>/PLANS/testing/test_policy.md`
- `<project>/PLANS/testing/nonfunctional_policy.md`
- `<project>/PLANS/testing/ai_code_safety_policy.md`

Required distinction:

- shared policy source lives in `agent-backbone/policies/`
- project-local binding lives in the consuming repository

## Boundary

Do not store consuming-project testing policy in `agent-backbone/PLANS/testing/`
unless the task is specifically about this repository itself.
