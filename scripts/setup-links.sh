#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# agent-marketing-waza: Multi-Agent Setup & Symlink Manager
# Supports: Antigravity, GitHub Copilot, Claude Code
# ==============================================================================

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_NAME="agent-marketing-waza"

usage() {
  cat <<EOF
Usage: $(basename "$0") [COMMAND]

Commands:
  --global                 Link agents and skills globally (~/.gemini, ~/.claude, ~/.copilot)
                           * Safe by default: does NOT inject always-on global rules into ~/.claude/rules
                             so your everyday coding tasks are never interrupted.
  --global-with-rules      Link agents, skills, AND always-on rules globally
  --project <target-dir>   Link rules, agents, and skills into a specific project directory
  --self                   Link into this repository itself (.agents, .claude, .github) for local use
  --status                 Show current agents, skills, and active global symlink status
  --unlink-global          Safely remove global symlinks pointing to this repository
  --unlink-project <dir>   Safely remove project symlinks pointing to this repository
  -h, --help               Show this help message
EOF
}

log_info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$1"; }
log_ok()    { printf "\033[1;32m[OK]\033[0m    %s\n" "$1"; }
log_skip()  { printf "\033[1;33m[SKIP]\033[0m  %s\n" "$1"; }

safe_symlink() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    local current_target
    current_target="$(readlink "$dst")"
    if [ "$current_target" = "$src" ]; then
      log_ok "Already linked: $dst -> $src"
      return 0
    fi
    rm "$dst"
  elif [ -e "$dst" ]; then
    log_skip "Exists and is not a symlink (skipped to protect existing file): $dst"
    return 0
  fi

  ln -s "$src" "$dst"
  log_ok "Linked: $dst -> $src"
}

remove_repo_symlinks_in_dir() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  for item in "$dir"/*; do
    [ -L "$item" ] || continue
    local target
    target="$(readlink "$item")"
    if [[ "$target" == "$REPO_ROOT"* ]]; then
      rm "$item"
      log_ok "Removed symlink: $item"
    fi
  done
}

# Collect valid agent markdown files (skips _template.md and README.md)
collect_agents() {
  local dir
  for dir in "$REPO_ROOT/agents" "$REPO_ROOT/local/agents"; do
    [ -d "$dir" ] || continue
    for f in "$dir"/*.md; do
      [ -e "$f" ] || continue
      local base
      base="$(basename "$f")"
      [[ "$base" == _* || "$base" == "README.md" ]] && continue
      echo "$f"
    done
  done
}

# Collect valid skill directories (skips _template and dirs without SKILL.md)
collect_skills() {
  local dir
  for dir in "$REPO_ROOT/skills" "$REPO_ROOT/local/skills"; do
    [ -d "$dir" ] || continue
    for sdir in "$dir"/*/; do
      [ -d "$sdir" ] || continue
      sdir="${sdir%/}"
      local base
      base="$(basename "$sdir")"
      [[ "$base" == _* ]] && continue
      [ -f "$sdir/SKILL.md" ] || continue
      echo "$sdir"
    done
  done
}

# Collect valid rule markdown files
collect_rules() {
  local dir
  for dir in "$REPO_ROOT/rules" "$REPO_ROOT/local/rules"; do
    [ -d "$dir" ] || continue
    for f in "$dir"/*.md; do
      [ -e "$f" ] || continue
      local base
      base="$(basename "$f")"
      [[ "$base" == _* || "$base" == "README.md" ]] && continue
      echo "$f"
    done
  done
}

install_global() {
  local include_rules="${1:-false}"
  log_info "Setting up GLOBAL links from: $REPO_ROOT"

  # 1. Antigravity Global Plugin
  safe_symlink "$REPO_ROOT" "$HOME/.gemini/config/plugins/$PLUGIN_NAME"

  # 2. Claude Code Global (~/.claude/{agents,skills})
  mkdir -p "$HOME/.claude/agents" "$HOME/.claude/skills"
  if [ "$include_rules" = "true" ]; then
    mkdir -p "$HOME/.claude/rules"
    if [ -f "$REPO_ROOT/rules/AGENTS.md" ]; then
      safe_symlink "$REPO_ROOT/rules/AGENTS.md" "$HOME/.claude/rules/${PLUGIN_NAME}-agents.md"
    fi
    for rfile in $(collect_rules); do
      local rbase
      rbase="$(basename "$rfile")"
      [ "$rbase" = "AGENTS.md" ] && continue
      safe_symlink "$rfile" "$HOME/.claude/rules/${PLUGIN_NAME}-${rbase}"
    done
  fi

  # 3. GitHub Copilot Global (~/.copilot/{agents,skills})
  mkdir -p "$HOME/.copilot/agents" "$HOME/.copilot/skills"

  # Link Agents to Claude Code & GitHub Copilot
  local agent_count=0
  for afile in $(collect_agents); do
    local abase aname
    abase="$(basename "$afile")"
    aname="${abase%.md}"
    safe_symlink "$afile" "$HOME/.claude/agents/$abase"
    safe_symlink "$afile" "$HOME/.copilot/agents/${aname}.agent.md"
    agent_count=$((agent_count + 1))
  done

  # Link Skills to Claude Code & GitHub Copilot
  local skill_count=0
  for sdir in $(collect_skills); do
    local sname
    sname="$(basename "$sdir")"
    safe_symlink "$sdir" "$HOME/.claude/skills/$sname"
    safe_symlink "$sdir" "$HOME/.copilot/skills/$sname"
    skill_count=$((skill_count + 1))
  done

  log_info "Global setup complete! (Active Agents: $agent_count, Active Skills: $skill_count)"
}

install_project() {
  local target_dir="$1"
  if [ ! -d "$target_dir" ]; then
    echo "Error: Target directory does not exist: $target_dir" >&2
    exit 1
  fi
  target_dir="$(cd "$target_dir" && pwd)"
  log_info "Setting up PROJECT links in: $target_dir"

  # 1. Root Orchestration Rules (AGENTS.md & CLAUDE.md)
  if [ -f "$REPO_ROOT/rules/AGENTS.md" ]; then
    safe_symlink "$REPO_ROOT/rules/AGENTS.md" "$target_dir/AGENTS.md"
    if [ ! -e "$target_dir/CLAUDE.md" ]; then
      printf "@AGENTS.md\n" > "$target_dir/CLAUDE.md"
      log_ok "Created $target_dir/CLAUDE.md (imports @AGENTS.md)"
    fi
  fi

  # 2. Agents (.agents/agents, .claude/agents, .github/agents)
  for afile in $(collect_agents); do
    local abase aname
    abase="$(basename "$afile")"
    aname="${abase%.md}"
    safe_symlink "$afile" "$target_dir/.agents/agents/$abase"
    safe_symlink "$afile" "$target_dir/.claude/agents/$abase"
    safe_symlink "$afile" "$target_dir/.github/agents/${aname}.agent.md"
  done

  # 3. Skills (.agents/skills, .claude/skills)
  for sdir in $(collect_skills); do
    local sname
    sname="$(basename "$sdir")"
    safe_symlink "$sdir" "$target_dir/.agents/skills/$sname"
    safe_symlink "$sdir" "$target_dir/.claude/skills/$sname"
  done

  log_info "Project setup complete for: $target_dir"
}

unlink_global() {
  log_info "Removing global symlinks pointing to $REPO_ROOT..."
  if [ -L "$HOME/.gemini/config/plugins/$PLUGIN_NAME" ]; then
    rm "$HOME/.gemini/config/plugins/$PLUGIN_NAME"
    log_ok "Removed symlink: $HOME/.gemini/config/plugins/$PLUGIN_NAME"
  fi
  remove_repo_symlinks_in_dir "$HOME/.claude/rules"
  remove_repo_symlinks_in_dir "$HOME/.claude/agents"
  remove_repo_symlinks_in_dir "$HOME/.claude/skills"
  remove_repo_symlinks_in_dir "$HOME/.copilot/agents"
  remove_repo_symlinks_in_dir "$HOME/.copilot/skills"
  log_info "Global unlink complete."
}

unlink_project() {
  local target_dir="$1"
  [ -d "$target_dir" ] || exit 1
  target_dir="$(cd "$target_dir" && pwd)"
  log_info "Removing project symlinks in $target_dir pointing to $REPO_ROOT..."
  if [ -L "$target_dir/AGENTS.md" ] && [[ "$(readlink "$target_dir/AGENTS.md")" == "$REPO_ROOT"* ]]; then
    rm "$target_dir/AGENTS.md"
    log_ok "Removed symlink: $target_dir/AGENTS.md"
  fi
  remove_repo_symlinks_in_dir "$target_dir/.agents/agents"
  remove_repo_symlinks_in_dir "$target_dir/.agents/skills"
  remove_repo_symlinks_in_dir "$target_dir/.claude/agents"
  remove_repo_symlinks_in_dir "$target_dir/.claude/skills"
  remove_repo_symlinks_in_dir "$target_dir/.github/agents"
  log_info "Project unlink complete."
}

show_status() {
  echo "=================================================================="
  echo " Repository: $REPO_ROOT"
  echo "=================================================================="
  echo ""
  echo "[Active Agents in Repository (excluding _template.md)]"
  local agents
  agents="$(collect_agents)"
  if [ -z "$agents" ]; then
    echo "  (none yet - copy agents/_template.md to agents/<name>.md to create one)"
  else
    for a in $agents; do echo "  - $(basename "$a") ($a)"; done
  fi

  echo ""
  echo "[Active Skills in Repository (excluding _template)]"
  local skills
  skills="$(collect_skills)"
  if [ -z "$skills" ]; then
    echo "  (none yet - copy skills/_template to skills/<name> to create one)"
  else
    for s in $skills; do echo "  - $(basename "$s") ($s/SKILL.md)"; done
  fi

  echo ""
  echo "[Global Link Status]"
  if [ -L "$HOME/.gemini/config/plugins/$PLUGIN_NAME" ]; then
    echo "  - Antigravity Plugin : LINKED ($HOME/.gemini/config/plugins/$PLUGIN_NAME)"
  else
    echo "  - Antigravity Plugin : not linked"
  fi
  if [ -L "$HOME/.claude/rules/${PLUGIN_NAME}-agents.md" ]; then
    echo "  - Claude Global Rule : LINKED ($HOME/.claude/rules/${PLUGIN_NAME}-agents.md)"
  else
    echo "  - Claude Global Rule : not linked (On-Demand mode)"
  fi
  echo "=================================================================="
}

case "${1:-}" in
  --global)
    install_global "false"
    ;;
  --global-with-rules)
    install_global "true"
    ;;
  --project)
    [ -n "${2:-}" ] || { echo "Error: --project requires a target directory path" >&2; exit 1; }
    install_project "$2"
    ;;
  --self)
    install_project "$REPO_ROOT"
    ;;
  --unlink-global)
    unlink_global
    ;;
  --unlink-project)
    [ -n "${2:-}" ] || { echo "Error: --unlink-project requires a target directory path" >&2; exit 1; }
    unlink_project "$2"
    ;;
  --status)
    show_status
    ;;
  *)
    usage
    exit 1
    ;;
esac
