#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install generated Claude slash-command wrappers for the agent-backbone skill catalog.

Usage:
  scripts/install_claude_skill_commands.sh [options]

Options:
  --dest PATH       Destination directory for Claude commands.
                    Default: $HOME/.claude/commands/agent-backbone
  --prefix STR      Prefix for generated command names (default: ab-).
  --no-router       Do not generate the catalog router command.
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

write_command_wrapper() {
  local command_path="$1"
  local command_name="$2"
  local description="$3"
  local source_file="$4"
  local repo_root="$5"

  cat >"$command_path" <<EOF
---
description: $(yaml_quote "$description [agent-backbone]")
---

# /$command_name

Use the canonical agent-backbone skill as source of truth:
- \`$source_file\`

Execution workflow:
1. Open and follow the canonical skill file exactly.
2. Load shared references from \`$repo_root/skills/references/\` only as needed.
3. Preserve deterministic verification boundaries before any judge-based evaluation.
4. Keep correctness, safety, and nonfunctional readiness as separate tracks.
5. Keep project-specific details in project docs; do not mutate canonical catalog behavior.
EOF
}

write_router_command() {
  local command_path="$1"
  local command_name="$2"
  local repo_root="$3"

  cat >"$command_path" <<EOF
---
description: "Route to the correct agent-backbone deterministic, stochastic, or orchestration skill."
---

# /$command_name

Route workflow using the agent-backbone catalog.

Primary catalog:
- \`$repo_root/skills/README.md\`

Skill directories:
- \`$repo_root/skills/deterministic/\`
- \`$repo_root/skills/stochastic/\`
- \`$repo_root/skills/orchestration/\`
- \`$repo_root/skills/k8s/edgespine/\`

Routing rules:
1. Classify request by oracle type and ownership.
2. Load the minimal required canonical skill set.
3. Enforce deterministic checks before semantic/judge flows.
4. Require explicit project bindings (test policy, safety policy, nonfunctional policy, architecture, contracts).
EOF
}

main() {
  local script_dir repo_root catalog_root dest_root prefix install_router dry_run
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  repo_root="$(cd "$script_dir/.." && pwd)"
  catalog_root="$repo_root/skills"
  dest_root="$HOME/.claude/commands/agent-backbone"
  prefix="ab-"
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
    {
      find "$catalog_root/deterministic" "$catalog_root/stochastic" "$catalog_root/orchestration" \
        -maxdepth 1 -type f -name '*.md' 2>/dev/null
      if [[ -d "$catalog_root/k8s/edgespine" ]]; then
        find "$catalog_root/k8s/edgespine" -type f -name '*.md'
      fi
    } | sort
  )

  if [[ ${#skill_files[@]} -eq 0 ]]; then
    echo "No skill markdown files found under $catalog_root." >&2
    return 1
  fi

  if [[ $dry_run -eq 0 ]]; then
    mkdir -p "$dest_root"
  fi

  local manifest_path="$dest_root/.agent-backbone-commands.tsv"
  local -a manifest_lines=()
  local created=0

  for source_file in "${skill_files[@]}"; do
    local base_name canonical_name canonical_desc command_name command_path marker_path
    base_name="$(basename "${source_file%.md}")"
    canonical_name="$(extract_frontmatter_field "$source_file" "name")"
    canonical_desc="$(extract_frontmatter_field "$source_file" "description")"
    [[ -n "$canonical_name" ]] || canonical_name="$base_name"
    [[ -n "$canonical_desc" ]] || canonical_desc="Run agent-backbone skill $canonical_name."

    command_name="${prefix}${canonical_name}"
    command_path="$dest_root/$command_name.md"
    marker_path="$dest_root/$command_name.generated-by-agent-backbone"
    manifest_lines+=("${command_name}\t${source_file}")

    if [[ $dry_run -eq 1 ]]; then
      echo "DRY-RUN write: $command_path -> $source_file"
    else
      write_command_wrapper "$command_path" "$command_name" "$canonical_desc" "$source_file" "$repo_root"
      printf '%s\n' "$source_file" >"$marker_path"
    fi
    created=$((created + 1))
  done

  if [[ $install_router -eq 1 ]]; then
    local router_name router_path router_marker
    router_name="${prefix}catalog-router"
    router_path="$dest_root/$router_name.md"
    router_marker="$dest_root/$router_name.generated-by-agent-backbone"
    manifest_lines+=("${router_name}\t${repo_root}/skills/README.md")

    if [[ $dry_run -eq 1 ]]; then
      echo "DRY-RUN write: $router_path -> $repo_root/skills/README.md"
    else
      write_router_command "$router_path" "$router_name" "$repo_root"
      printf '%s\n' "$repo_root/skills/README.md" >"$router_marker"
    fi
    created=$((created + 1))
  fi

  if [[ $dry_run -eq 1 ]]; then
    echo "DRY-RUN complete. Command wrappers planned: $created"
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

  echo "Installed $created Claude command wrappers under: $dest_root"
  echo "Manifest: $manifest_path"
  echo "Restart Claude Code session to pick up new commands."
}

main "$@"
