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
  --profile NAME    Install only skills listed in registry/profiles/NAME.yaml.
  --list-profiles   Print available registry profiles and exit.
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

manifest_skill_names() {
  local manifest_path="$1"
  [[ -f "$manifest_path" ]] || return 0

  awk -F '\t' '
    $1 != "generated_at" && $1 != "repo_root" && $1 != "dest_root" && NF >= 2 {
      print $1
    }
  ' "$manifest_path"
}

list_profiles() {
  local profiles_dir="$1"
  if [[ ! -d "$profiles_dir" ]]; then
    echo "No profiles directory found: $profiles_dir" >&2
    return 1
  fi

  find "$profiles_dir" -maxdepth 1 -type f -name '*.yaml' -print \
    | sort \
    | while IFS= read -r file; do
        basename "${file%.yaml}"
      done
}

profile_skill_ids() {
  local profile_file="$1"
  awk '
    /^skills:[[:space:]]*$/ { in_skills = 1; next }
    in_skills && /^[^[:space:]-]/ { exit }
    in_skills && /^[[:space:]]*-[[:space:]]*/ {
      line = $0
      sub(/^[[:space:]]*-[[:space:]]*/, "", line)
      print line
    }
  ' "$profile_file"
}

repo_path_for_skill_id() {
  local registry_file="$1"
  local target_id="$2"
  awk -v target_id="$target_id" '
    $1 == "-" && $2 == "canonical_id:" {
      current = $3
      next
    }
    current == target_id && $1 == "repo_path:" {
      print $2
      exit
    }
  ' "$registry_file"
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
  local script_dir repo_root catalog_root dest_root prefix install_router dry_run profile_name list_profiles_only registry_dir registry_file
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  repo_root="$(cd "$script_dir/.." && pwd)"
  catalog_root="$repo_root/skills"
  registry_dir="$repo_root/registry/profiles"
  registry_file="$repo_root/registry/skills.yaml"
  dest_root="$HOME/.claude/commands/agent-backbone"
  prefix="ab-"
  install_router=1
  dry_run=0
  profile_name=""
  list_profiles_only=0

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
      --profile)
        profile_name="$2"
        shift 2
        ;;
      --list-profiles)
        list_profiles_only=1
        shift
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

  if [[ $list_profiles_only -eq 1 ]]; then
    list_profiles "$registry_dir"
    return 0
  fi

  if [[ ! -d "$catalog_root" ]]; then
    echo "Catalog not found: $catalog_root" >&2
    return 1
  fi

  local -a skill_files=()
  if [[ -n "$profile_name" ]]; then
    local profile_file
    profile_file="$registry_dir/$profile_name.yaml"
    [[ -f "$profile_file" ]] || {
      echo "Unknown profile: $profile_name" >&2
      return 1
    }
    [[ -f "$registry_file" ]] || {
      echo "Registry not found: $registry_file" >&2
      return 1
    }

    while IFS= read -r skill_id; do
      [[ -n "$skill_id" ]] || continue
      local repo_path
      repo_path="$(repo_path_for_skill_id "$registry_file" "$skill_id")"
      [[ -n "$repo_path" ]] || {
        echo "Skill id missing from registry: $skill_id" >&2
        return 1
      }
      skill_files+=("$repo_root/$repo_path")
    done < <(profile_skill_ids "$profile_file")
  else
    while IFS= read -r file; do
      skill_files+=("$file")
    done < <(
      find "$catalog_root" -type f -name '*.md' \
        ! -path '*/references/*' \
        ! -path '*/README.md' \
        | sort
    )
  fi

  if [[ ${#skill_files[@]} -eq 0 ]]; then
    echo "No installable skill markdown files found." >&2
    return 1
  fi

  if [[ $dry_run -eq 0 ]]; then
    mkdir -p "$dest_root"
  fi

  local manifest_path="$dest_root/.agent-backbone-commands.tsv"
  local -a manifest_lines=()
  local -a previous_names=()
  local -a current_names=()

  while IFS= read -r name; do
    [[ -n "$name" ]] || continue
    previous_names+=("$name")
  done < <(manifest_skill_names "$manifest_path")
  local created=0

  for source_file in "${skill_files[@]}"; do
    local base_name canonical_name canonical_desc command_name command_path marker_path
    base_name="$(basename "${source_file%.md}")"
    canonical_name="$(extract_frontmatter_field "$source_file" "name")"
    canonical_desc="$(extract_frontmatter_field "$source_file" "description")"
    [[ -n "$canonical_name" ]] || canonical_name="$base_name"
    [[ -n "$canonical_desc" ]] || canonical_desc="Run agent-backbone skill $canonical_name."

    command_name="${prefix}${canonical_name}"
    current_names+=("$command_name")
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
    current_names+=("$router_name")
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
    if [[ ${#previous_names[@]} -gt 0 ]]; then
      for old_name in "${previous_names[@]}"; do
        local keep=0
        for current_name in "${current_names[@]}"; do
          if [[ "$old_name" == "$current_name" ]]; then
            keep=1
            break
          fi
        done
        if [[ $keep -eq 0 ]]; then
          echo "DRY-RUN remove stale command: $dest_root/$old_name.md"
        fi
      done
    fi
    echo "DRY-RUN complete. Command wrappers planned: $created"
    return 0
  fi

  if [[ ${#previous_names[@]} -gt 0 ]]; then
    for old_name in "${previous_names[@]}"; do
      local keep=0
      for current_name in "${current_names[@]}"; do
        if [[ "$old_name" == "$current_name" ]]; then
          keep=1
          break
        fi
      done
      if [[ $keep -eq 0 ]]; then
        local stale_path="$dest_root/$old_name.md"
        local stale_marker="$dest_root/$old_name.generated-by-agent-backbone"
        if [[ -f "$stale_marker" ]]; then
          rm -f "$stale_path" "$stale_marker"
        fi
      fi
    done
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
  echo "Re-running this command is safe; stale generated commands are pruned."
  echo "Restart Claude Code session to pick up new commands."
}

main "$@"
