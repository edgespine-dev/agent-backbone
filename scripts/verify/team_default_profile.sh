#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
profile="$repo_root/registry/profiles/team-default.yaml"

[[ -f "$profile" ]] || { echo "missing profile: $profile" >&2; exit 1; }

for id in \
  k8s/edgespine/edgespine-argo-gitops-triage \
  k8s/edgespine/edgespine-deployment-router \
  k8s/edgespine/edgespine-overlay-and-placement-review \
  k8s/edgespine/edgespine-runtime-debug-readonly \
  k8s/edgespine/edgespine-secrets-and-db-wiring-review \
  k8s/edgespine/edgespine-storage-policy-review
do
  rg -q "$id" "$profile" || {
    echo "team-default profile missing skill: $id" >&2
    exit 1
  }
done

codex_dry_run="$(cd "$repo_root" && ./scripts/codex_install.sh --profile team-default --dry-run)"
claude_dry_run="$(cd "$repo_root" && ./scripts/claude_install.sh --profile team-default --dry-run)"

for skill_name in \
  edgespine-argo-gitops-triage \
  edgespine-deployment-router \
  edgespine-overlay-and-placement-review \
  edgespine-runtime-debug-readonly \
  edgespine-secrets-and-db-wiring-review \
  edgespine-storage-policy-review
do
  printf '%s\n' "$codex_dry_run" | rg -q "$skill_name" || {
    echo "codex team-default dry-run missing skill: $skill_name" >&2
    exit 1
  }
  printf '%s\n' "$claude_dry_run" | rg -q "$skill_name" || {
    echo "claude team-default dry-run missing skill: $skill_name" >&2
    exit 1
  }
done

echo "team-default profile verify ok"
