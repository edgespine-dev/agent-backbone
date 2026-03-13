#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
registry="$repo_root/registry/skills.yaml"

required_ids=(
  "k8s/edgespine/edgespine-argo-gitops-triage"
  "k8s/edgespine/edgespine-deployment-router"
  "k8s/edgespine/edgespine-overlay-and-placement-review"
  "k8s/edgespine/edgespine-runtime-debug-readonly"
  "k8s/edgespine/edgespine-secrets-and-db-wiring-review"
  "k8s/edgespine/edgespine-storage-policy-review"
)

required_paths=(
  "$repo_root/skills/k8s/edgespine/edgespine-argo-gitops-triage.md"
  "$repo_root/skills/k8s/edgespine/edgespine-deployment-router.md"
  "$repo_root/skills/k8s/edgespine/edgespine-overlay-and-placement-review.md"
  "$repo_root/skills/k8s/edgespine/edgespine-runtime-debug-readonly.md"
  "$repo_root/skills/k8s/edgespine/edgespine-secrets-and-db-wiring-review.md"
  "$repo_root/skills/k8s/edgespine/edgespine-storage-policy-review.md"
  "$repo_root/skills/k8s/references/source-of-truth.md"
  "$repo_root/skills/k8s/references/classification-and-guardrails.md"
  "$repo_root/skills/k8s/references/conflict-matrix.md"
)

for p in "$registry" "${required_paths[@]}"; do
  [[ -f "$p" ]] || { echo "missing file: $p" >&2; exit 1; }
done

for id in "${required_ids[@]}"; do
  rg -q "canonical_id: ${id}$" "$registry" || {
    echo "missing registry id: $id" >&2
    exit 1
  }
done

for md in "$repo_root"/skills/k8s/edgespine/*.md; do
  skill_name="$(basename "${md%.md}")"
  rg -q "name: ${skill_name}$" "$registry" || {
    echo "ghost skill file not registered: $md" >&2
    exit 1
  }
done

for id in "${required_ids[@]}"; do
  skill_name="${id##*/}"
  expected_path="repo_path: skills/k8s/edgespine/${skill_name}.md"
  rg -q "$expected_path" "$registry" || {
    echo "missing or mismatched repo_path for: $skill_name" >&2
    exit 1
  }
done

for profile in k8s full legacy; do
  f="$repo_root/registry/profiles/${profile}.yaml"
  [[ -f "$f" ]] || { echo "missing profile file: $f" >&2; exit 1; }
  for id in "${required_ids[@]}"; do
    rg -q "$id" "$f" || {
      echo "missing id in profile ${profile}: $id" >&2
      exit 1
    }
  done
done

for wrapper in \
  /home/esadmin/bakerlabs-k8s/skills/edgespine/deployment/edgespine-argo-gitops-triage/SKILL.md \
  /home/esadmin/bakerlabs-k8s/skills/edgespine/deployment/edgespine-deployment-router/SKILL.md \
  /home/esadmin/bakerlabs-k8s/skills/edgespine/deployment/edgespine-overlay-and-placement-review/SKILL.md \
  /home/esadmin/bakerlabs-k8s/skills/edgespine/deployment/edgespine-runtime-debug-readonly/SKILL.md \
  /home/esadmin/bakerlabs-k8s/skills/edgespine/policy/edgespine-secrets-and-db-wiring-review/SKILL.md \
  /home/esadmin/bakerlabs-k8s/skills/edgespine/policy/edgespine-storage-policy-review/SKILL.md
 do
  [[ -f "$wrapper" ]] || { echo "missing compatibility wrapper: $wrapper" >&2; exit 1; }
  if ! rg -q "Compatibility wrapper for migration|Generated pointer wrapper to the canonical agent-backbone skill" "$wrapper"; then
    echo "wrapper missing compatibility marker: $wrapper" >&2
    exit 1
  fi
  skill_name="$(basename "$(dirname "$wrapper")")"
  rg -q "/home/esadmin/agent-backbone/skills/k8s/edgespine/${skill_name}.md" "$wrapper" || {
    echo "wrapper missing canonical target: $wrapper" >&2
    exit 1
  }
done

codex_dry_run="$(cd "$repo_root" && ./scripts/codex_install.sh --dry-run)"
claude_dry_run="$(cd "$repo_root" && ./scripts/claude_install.sh --dry-run)"
for skill_name in \
  edgespine-argo-gitops-triage \
  edgespine-deployment-router \
  edgespine-overlay-and-placement-review \
  edgespine-runtime-debug-readonly \
  edgespine-secrets-and-db-wiring-review \
  edgespine-storage-policy-review
 do
  printf '%s\n' "$codex_dry_run" | rg -q "$skill_name" || {
    echo "codex dry-run missing skill: $skill_name" >&2
    exit 1
  }
  printf '%s\n' "$claude_dry_run" | rg -q "$skill_name" || {
    echo "claude dry-run missing skill: $skill_name" >&2
    exit 1
  }
done

echo "edgespine migration verify ok"
