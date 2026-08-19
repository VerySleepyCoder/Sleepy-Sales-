#!/usr/bin/env bash
#
# install.sh — Install the agent library into an AI coding tool's agents directory.
#
# Usage:
#   ./scripts/install.sh [--tool <name>] [--dest <dir>] [--dry-run] [--force] [--list] [categories...]
#
# Examples:
#   ./scripts/install.sh --tool claude-code                 # install every agent
#   ./scripts/install.sh --tool claude-code engineering     # install one division
#   ./scripts/install.sh --tool claude-code engineering design
#   ./scripts/install.sh --list                             # list available divisions/agents
#   ./scripts/install.sh --tool claude-code --dry-run       # preview without copying
#   ./scripts/install.sh --dest ~/my-agents                 # install to a custom directory
#
set -euo pipefail

# --- resolve repository root (directory that contains this script's parent) -----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# --- defaults -------------------------------------------------------------------
TOOL="claude-code"
DEST=""
DRY_RUN=0
FORCE=0
LIST=0
CATEGORIES=()

# Directories in the repo that are NOT agent divisions.
NON_DIVISION_DIRS=(".git" ".github" "scripts" "docs" "node_modules")

# --- helpers --------------------------------------------------------------------
color()  { if [ -t 1 ]; then printf '\033[%sm%s\033[0m' "$1" "$2"; else printf '%s' "$2"; fi; }
info()   { printf '%s %s\n' "$(color '1;34' '::')" "$*"; }
ok()     { printf '%s %s\n' "$(color '1;32' '✓')" "$*"; }
warn()   { printf '%s %s\n' "$(color '1;33' '!')" "$*" >&2; }
die()    { printf '%s %s\n' "$(color '1;31' '✗')" "$*" >&2; exit 1; }

usage() {
  sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# Map a tool name to its default agents destination directory.
dest_for_tool() {
  case "$1" in
    claude-code|claude) printf '%s/.claude/agents' "${HOME}" ;;
    cursor)             printf '%s/.cursor/agents' "${HOME}" ;;
    opencode|open-code) printf '%s/.config/opencode/agents' "${HOME}" ;;
    *) return 1 ;;
  esac
}

# Is $1 one of the non-division directories?
is_non_division() {
  local d
  for d in "${NON_DIVISION_DIRS[@]}"; do
    [ "$1" = "$d" ] && return 0
  done
  return 1
}

# Print every division directory (basename) that contains at least one .md agent.
discover_divisions() {
  local dir base
  for dir in "${REPO_ROOT}"/*/; do
    base="$(basename "$dir")"
    is_non_division "$base" && continue
    # only count directories that actually hold agent markdown files
    if compgen -G "${dir}*.md" > /dev/null; then
      printf '%s\n' "$base"
    fi
  done
}

# --- argument parsing -----------------------------------------------------------
while [ $# -gt 0 ]; do
  case "$1" in
    --tool)     TOOL="${2:?--tool requires a value}"; shift 2 ;;
    --tool=*)   TOOL="${1#*=}"; shift ;;
    --dest)     DEST="${2:?--dest requires a value}"; shift 2 ;;
    --dest=*)   DEST="${1#*=}"; shift ;;
    --dry-run)  DRY_RUN=1; shift ;;
    --force)    FORCE=1; shift ;;
    --list)     LIST=1; shift ;;
    -h|--help)  usage 0 ;;
    -*)         die "Unknown option: $1 (try --help)" ;;
    *)          CATEGORIES+=("$1"); shift ;;
  esac
done

# --- --list short-circuit -------------------------------------------------------
if [ "${LIST}" -eq 1 ]; then
  info "Available divisions and agents:"
  while IFS= read -r division; do
    printf '\n  %s\n' "$(color '1;36' "${division}/")"
    for f in "${REPO_ROOT}/${division}"/*.md; do
      [ -e "$f" ] || continue
      printf '    - %s\n' "$(basename "${f%.md}")"
    done
  done < <(discover_divisions)
  printf '\n'
  exit 0
fi

# --- resolve destination --------------------------------------------------------
if [ -z "${DEST}" ]; then
  DEST="$(dest_for_tool "${TOOL}")" || die "Unknown --tool '${TOOL}'. Supported: claude-code, cursor, opencode. Or pass --dest <dir>."
fi
# expand a leading ~ if the user quoted it
DEST="${DEST/#\~/${HOME}}"

# --- resolve which divisions to install ----------------------------------------
mapfile -t ALL_DIVISIONS < <(discover_divisions)
[ "${#ALL_DIVISIONS[@]}" -gt 0 ] || die "No agent divisions found in ${REPO_ROOT}"

if [ "${#CATEGORIES[@]}" -eq 0 ]; then
  SELECTED=("${ALL_DIVISIONS[@]}")
else
  SELECTED=()
  for cat in "${CATEGORIES[@]}"; do
    found=0
    for d in "${ALL_DIVISIONS[@]}"; do
      [ "$cat" = "$d" ] && { SELECTED+=("$d"); found=1; break; }
    done
    [ "$found" -eq 1 ] || warn "No such division: '${cat}' (skipping)"
  done
  [ "${#SELECTED[@]}" -gt 0 ] || die "None of the requested divisions exist. Try --list."
fi

# --- install --------------------------------------------------------------------
info "Tool:        ${TOOL}"
info "Destination: ${DEST}"
info "Divisions:   ${SELECTED[*]}"
[ "${DRY_RUN}" -eq 1 ] && warn "Dry run — no files will be written."

if [ "${DRY_RUN}" -eq 0 ]; then
  mkdir -p "${DEST}"
fi

installed=0
skipped=0
for division in "${SELECTED[@]}"; do
  for src in "${REPO_ROOT}/${division}"/*.md; do
    [ -e "$src" ] || continue
    name="$(basename "$src")"
    dst="${DEST}/${name}"

    if [ -e "$dst" ] && [ "${FORCE}" -eq 0 ] && ! cmp -s "$src" "$dst"; then
      warn "exists, use --force to overwrite: ${name}"
      skipped=$((skipped + 1))
      continue
    fi

    if [ "${DRY_RUN}" -eq 1 ]; then
      printf '  would install %s → %s\n' "${division}/${name}" "${dst}"
    else
      cp "$src" "$dst"
      printf '  installed %s\n' "${division}/${name}"
    fi
    installed=$((installed + 1))
  done
done

printf '\n'
if [ "${DRY_RUN}" -eq 1 ]; then
  ok "Dry run complete: ${installed} agent(s) would be installed, ${skipped} skipped."
else
  ok "Installed ${installed} agent(s) to ${DEST} (${skipped} skipped)."
  info "Activate one in a session, e.g.: \"Activate Frontend Developer mode and help me build a React component.\""
fi
