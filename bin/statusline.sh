#!/usr/bin/env bash
# Claude Code statusline — model, auth, branch/path, context bar, session time, churn
# Receives JSON session data via stdin
# Part of: aesirsystems/claude-workflow-tools

set -euo pipefail

INPUT=$(cat)

# Single jq call for all fields
eval "$(echo "$INPUT" | jq -r '
  @sh "MODEL=\(.model.display_name // "?")",
  @sh "CTX_PCT=\(.context_window.used_percentage // 0 | floor)",
  @sh "CTX_SIZE=\(.context_window.context_window_size // 200000)",
  @sh "LINES_ADD=\(.cost.total_lines_added // 0)",
  @sh "LINES_DEL=\(.cost.total_lines_removed // 0)",
  @sh "DURATION_MS=\(.cost.total_duration_ms // 0)",
  @sh "CWD=\(.workspace.current_dir // .cwd // "")"
')"

# Build model label: "Opus 4.6 200k" from display_name + context size
CTX_K=$(( CTX_SIZE / 1000 ))
MODEL="${MODEL} ${CTX_K}k"

# --- Cache infrastructure ---
CACHE_DIR="/tmp/.claude-statusline-cache"
mkdir -p "$CACHE_DIR"
AUTH_CACHE="$CACHE_DIR/auth"
BRANCH_CACHE="$CACHE_DIR/branch"
DIRTY_CACHE="$CACHE_DIR/dirty"

read_cache() {
  local file="$1" ttl="$2"
  if [[ -f "$file" ]] && [[ -s "$file" ]]; then
    local age=$(( $(date +%s) - $(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null || echo 0) ))
    if (( age < ttl )); then
      cat "$file"
      return 0
    fi
  fi
  return 1
}

# --- Auth (cached 300s — doesn't change mid-session) ---
if ! AUTH=$(read_cache "$AUTH_CACHE" 300); then
  if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
    AUTH="API"
  elif command -v security >/dev/null 2>&1 && security find-generic-password -s "Claude Code-credentials" >/dev/null 2>&1; then
    AUTH="Sub"
  else
    AUTH="?"
  fi
  echo "$AUTH" > "$AUTH_CACHE"
fi

# --- Git branch + dirty (cached 5s, sync on first miss then background) ---
IS_GIT=false
if ! BRANCH=$(read_cache "$BRANCH_CACHE" 5); then
  if [[ -n "$CWD" ]] && cd "$CWD" 2>/dev/null && GIT_OPTIONAL_LOCKS=0 git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    IS_GIT=true
    BRANCH=$(GIT_OPTIONAL_LOCKS=0 git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "detached")
    echo "$BRANCH" > "$BRANCH_CACHE"
    GIT_OPTIONAL_LOCKS=0 git status --porcelain 2>/dev/null | wc -l | tr -d ' ' > "$DIRTY_CACHE" &
  else
    BRANCH=""
    echo "" > "$BRANCH_CACHE"
  fi
else
  [[ -n "$BRANCH" ]] && IS_GIT=true
  # Background refresh for next call
  (
    if [[ -n "$CWD" ]] && cd "$CWD" 2>/dev/null && GIT_OPTIONAL_LOCKS=0 git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      GIT_OPTIONAL_LOCKS=0 git rev-parse --abbrev-ref HEAD 2>/dev/null > "$BRANCH_CACHE"
      GIT_OPTIONAL_LOCKS=0 git status --porcelain 2>/dev/null | wc -l | tr -d ' ' > "$DIRTY_CACHE"
    else
      echo "" > "$BRANCH_CACHE"
      echo "0" > "$DIRTY_CACHE"
    fi
  ) &
fi

DIRTY=$(cat "$DIRTY_CACHE" 2>/dev/null || echo "0")

# --- ANSI colors ---
RST='\033[0m'; B='\033[1m'; D='\033[2m'
RED='\033[31m'; GRN='\033[32m'; YLW='\033[33m'
BLU='\033[34m'; MAG='\033[35m'; CYN='\033[36m'
WHT='\033[37m'; BG_RED='\033[41m'

# --- Context bar (10 segments, color-coded) ---
filled=$(( CTX_PCT / 10 ))
empty=$(( 10 - filled ))

if (( CTX_PCT >= 80 )); then
  BC="$RED"; CL="${RED}${B}${CTX_PCT}%${RST}"
elif (( CTX_PCT >= 50 )); then
  BC="$YLW"; CL="${YLW}${CTX_PCT}%${RST}"
else
  BC="$GRN"; CL="${GRN}${CTX_PCT}%${RST}"
fi

BAR=""
for ((i=0; i<filled; i++)); do BAR+="▓"; done
for ((i=0; i<empty; i++)); do BAR+="░"; done
BAR="${BC}${BAR}${RST}"

# --- Extended context indicator (integrated into model label) ---
if (( CTX_SIZE > 200000 )); then
  MODEL="${MODEL} ${MAG}EXT${RST}"
fi

# --- Session duration ---
DUR=""
if (( DURATION_MS > 60000 )); then
  ts=$(( DURATION_MS / 1000 ))
  if (( ts >= 3600 )); then
    DUR=" ${D}|${RST} ${D}$(( ts / 3600 ))h$(( (ts % 3600) / 60 ))m${RST}"
  else
    DUR=" ${D}|${RST} ${D}$(( ts / 60 ))m$(( ts % 60 ))s${RST}"
  fi
fi

# --- Code churn ---
CHURN=""
(( LINES_ADD > 0 || LINES_DEL > 0 )) && \
  CHURN=" ${D}|${RST} ${GRN}+${LINES_ADD}${RST}/${RED}-${LINES_DEL}${RST}"

# --- Dirty file count (only in git repos) ---
DIRT=""
$IS_GIT && (( DIRTY > 0 )) && DIRT=" ${YLW}~${DIRTY}${RST}"

# --- Auth badge ---
AUTH_B=""
[[ "$AUTH" == "Sub" ]] && AUTH_B="${D}: ${RST}${GRN}Sub${RST}"
[[ "$AUTH" == "API" ]] && AUTH_B="${D}: ${RST}${YLW}API${RST}"

# --- Compact warning ---
WARN=""
(( CTX_PCT >= 85 )) && WARN=" ${BG_RED}${WHT}${B} /compact ${RST}"

# --- Location label ---
LOC=""
if $IS_GIT; then
  LOC="${BLU}${BRANCH}${RST}${DIRT}"
elif [[ -n "$CWD" ]]; then
  # Show compact path: ~/github/mitre instead of /Users/.../github/mitre
  DISPLAY_PATH="$(echo "$CWD" | sed "s|^${HOME:-/Users/$USER}|~|")"
  LOC="${D}${DISPLAY_PATH}${RST}"
fi

# --- Output ---
printf '%b' "${D}[${RST}${B}${CYN}${MODEL}${RST}${AUTH_B}${D}]${RST} ${LOC} ${BAR} ${CL}${DUR}${CHURN}${WARN}"
