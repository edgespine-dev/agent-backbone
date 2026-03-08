#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install generated SKILL.md pointer wrappers for the agent-backbone skill catalog.

Usage:
  scripts/install_codex_skill_wrappers.sh [options]

Options:
  --dest PATH       Destination skills directory.
                    Default: ${CODEX_HOME:-$HOME/.codex}/skills
  --prefix STR      Prefix for generated skill names (default: empty).
  --no-router       Do not generate the catalog router skill.
  --dry-run         Print planned writes without changing files.
  -h, --help        Show this help text.
EOF
}

extract_frontmatter_field() {
  local file="$1"
  local key="$2"
  awk -v key="$key" '
    BEGIN { in_fm = 0; dash_count = 0 }
    /^---[[:space:]]*$/ {
      dash_count++
      if (dash_count == 1) { in_fm = 1; next }
      if (dash_count == 2) { exit }
    }
    in_fm == 1 && $0 ~ ("^" key ":") {
      value = $0
      sub("^" key ":[[:space:]]*", "", value)
      gsub(/^"/, "", value)
      gsub(/"$/, "", value)
      print value
      exit
    }
  ' "$file"
}

yaml_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

write_wrapper() {
  local wrapper_path="$1"
  local name="$2"
  local description="$3"
  local source_file="$4"
  local repo_root="$5"

  cat >"$wrapper_path" <<EOF
---
name: $name
description: $(yaml_quote "$description")
---

# $name

Generated pointer wrapper to the canonical agent-backbone skill.

- Canonical skill: \`$source_file\`
- Catalog README: \`$repo_root/skills/README.md\`

When this wrapper is triggered:
1. Open and follow the canonical skill file as source of truth.
2. Load shared references from \`$repo_root/skills/references/\` when needed.
3. Preserve deterministic vs stochastic boundaries from \`$repo_root/skills/references/deterministic-vs-stochastic.md\`.
4. Keep project-specific bindings in project docs; keep canonical behavior in agent-backbone.
EOF
}

write_router() {
  local wrapper_path="$1"
  local name="$2"
  local repo_root="$3"

  cat >"$wrapper_path" <<EOF
---
name: $name
description: "Route work to the correct agent-backbone deterministic, stochastic, or orchestration skill."
---

# $name

Top-level router for the agent-backbone skill catalog.

- Canonical catalog: \`$repo_root/skills/README.md\`
- Skill folders:
  - \`$repo_root/skills/deterministic/\`
  - \`$repo_root/skills/stochastic/\`
  - \`$repo_root/skills/orchestration/\`

Routing workflow:
1. Read \`skills/README.md\` and classify the request by oracle type and scope.
2. Load the smallest set of canonical skills needed for the task.
3. Enforce deterministic correctness checks before judge-based or semantic evaluation.
4. Keep correctness, safety, and nonfunctional readiness as separate tracks.
EOF
}

main() {
  local script_dir repo_root catalog_root dest_root prefix install_router dry_run
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  repo_root="$(cd "$script_dir/.." && pwd)"
  catalog_root="$repo_root/skills"
  dest_root="${CODEX_HOME:-$HOME/.codex}/skills"
  prefix=""
  install_router=1
  dry_run=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dest)
        dest_root="$2"
        shift 2
        ;;
      --prefix)
        prefix="$2"
        shift 2
        ;;
      --no-router)
        install_router=0
        shift
        ;;
      --dry-run)
        dry_run=1
        shift
        ;;
      -h|--help)
        usage
        return 0
        ;;
      *)
        echo "Unknown argument: $1" >&2
        usage >&2
        return 2
        ;;
    esac
  done

  if [[ ! -d "$catalog_root" ]]; then
    echo "Catalog not found: $catalog_root" >&2
    return 1
  fi

  local -a skill_files=()
  while IFS= read -r file; do
    skill_files+=("$file")
  done < <(
    find "$catalog_root/deterministic" "$catalog_root/stochastic" "$catalog_root/orchestration" \
      -maxdepth 1 -type f -name '*.md' | sort
  )

  if [[ ${#skill_files[@]} -eq 0 ]]; then
    echo "No skill markdown files found under $catalog_root." >&2
    return 1
  fi

  if [[ $dry_run -eq 0 ]]; then
    mkdir -p "$dest_root"
  fi

  local manifest_path="$dest_root/.agent-backbone-wrappers.tsv"
  local -a manifest_lines=()

  local created=0
  for source_file in "${skill_files[@]}"; do
    local base_name canonical_name canonical_desc skill_name wrapper_dir wrapper_path marker_path
    base_name="$(basename "${source_file%.md}")"
    canonical_name="$(extract_frontmatter_field "$source_file" "name")"
    canonical_desc="$(extract_frontmatter_field "$source_file" "description")"
    [[ -n "$canonical_name" ]] || canonical_name="$base_name"
    [[ -n "$canonical_desc" ]] || canonical_desc="Pointer wrapper for $canonical_name from agent-backbone catalog."

    skill_name="${prefix}${canonical_name}"
    wrapper_dir="$dest_root/$skill_name"
    wrapper_path="$wrapper_dir/SKILL.md"
    marker_path="$wrapper_dir/.agent-backbone-wrapper"

    manifest_lines+=("${skill_name}\t${source_file}")

    if [[ $dry_run -eq 1 ]]; then
      echo "DRY-RUN write: $wrapper_path -> $source_file"
    else
      mkdir -p "$wrapper_dir"
      write_wrapper "$wrapper_path" "$skill_name" "$canonical_desc" "$source_file" "$repo_root"
      printf '%s\n' "$source_file" >"$marker_path"
    fi
    created=$((created + 1))
  done

  if [[ $install_router -eq 1 ]]; then
    local router_name router_dir router_path router_marker
    router_name="${prefix}agent-backbone-catalog-router"
    router_dir="$dest_root/$router_name"
    router_path="$router_dir/SKILL.md"
    router_marker="$router_dir/.agent-backbone-wrapper"
    manifest_lines+=("${router_name}\t${repo_root}/skills/README.md")

    if [[ $dry_run -eq 1 ]]; then
      echo "DRY-RUN write: $router_path -> $repo_root/skills/README.md"
    else
      mkdir -p "$router_dir"
      write_router "$router_path" "$router_name" "$repo_root"
      printf '%s\n' "$repo_root/skills/README.md" >"$router_marker"
    fi
    created=$((created + 1))
  fi

  if [[ $dry_run -eq 1 ]]; then
    echo "DRY-RUN complete. Wrappers planned: $created"
    return 0
  fi

  {
    printf 'generated_at\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'repo_root\t%s\n' "$repo_root"
    printf 'dest_root\t%s\n' "$dest_root"
    for line in "${manifest_lines[@]}"; do
      printf '%b\n' "$line"
    done
  } >"$manifest_path"

  echo "Installed $created wrappers under: $dest_root"
  echo "Manifest: $manifest_path"
  echo "Restart Codex to pick up newly installed skills."
}

main "$@"
