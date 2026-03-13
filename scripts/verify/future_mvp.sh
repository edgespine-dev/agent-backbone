#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
registry="$repo_root/registry/skills.yaml"
profile="$repo_root/registry/profiles/future-mvp.yaml"

required_files=(
  "$repo_root/skills/iot/esp32-embedded-runner.md"
  "$repo_root/skills/testing/sigrid-test-runner.md"
  "$registry"
  "$profile"
)

for f in "${required_files[@]}"; do
  [[ -f "$f" ]] || { echo "missing file: $f" >&2; exit 1; }
done

rg -q "canonical_id: iot/embedded/esp32-embedded-runner" "$registry" || {
  echo "missing registry entry: esp32-embedded-runner" >&2
  exit 1
}

rg -q "canonical_id: testing/sigrid/sigrid-test-runner" "$registry" || {
  echo "missing registry entry: sigrid-test-runner" >&2
  exit 1
}

rg -q "repo_path: skills/iot/esp32-embedded-runner.md" "$registry" || {
  echo "missing repo_path mapping: esp32-embedded-runner" >&2
  exit 1
}

rg -q "repo_path: skills/testing/sigrid-test-runner.md" "$registry" || {
  echo "missing repo_path mapping: sigrid-test-runner" >&2
  exit 1
}

rg -q "iot/embedded/esp32-embedded-runner" "$profile" || {
  echo "future-mvp profile missing esp32 id" >&2
  exit 1
}

rg -q "testing/sigrid/sigrid-test-runner" "$profile" || {
  echo "future-mvp profile missing sigrid id" >&2
  exit 1
}

echo "future mvp verify ok"
