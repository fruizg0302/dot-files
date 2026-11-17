#!/bin/sh
# ZCode -> Herdr lifecycle reporter.
# Registered as ZCode hooks (SessionStart, UserPromptSubmit, PreToolUse,
# PermissionRequest, PostToolUse, PostToolUseFailure, Stop) by scripts/setup.sh.
# Reads the hook JSON on stdin and reports the pane's agent state to Herdr.
# Outside a Herdr pane this does nothing.
set -u

if [ -z "${HC_TERMINAL_ID:-}" ]; then
  [ "${HERDR_ENV:-}" = "1" ] || exit 0
  [ -n "${HERDR_PANE_ID:-}" ] || exit 0
fi
HERDR="${HERDR_BIN_PATH:-herdr}"

SOURCE="zcode-hooks"
AGENT="zcode"

input="$(cat 2>/dev/null || true)"
[ -n "$input" ] || exit 0

if [ -n "${HC_TERMINAL_ID:-}" ]; then
  printf '%s' "$input" | python3 "$(dirname "$0")/desktop-state-hook.py" 2>/dev/null || true
  exit 0
fi

# Hook stdin is Claude-compatible snake_case; ZCode also sends camelCase aliases.
parse_input() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r '@sh "event=\(.hook_event_name // .hookEventName // "") sid=\(.session_id // .sessionId // "") reason=\(.reason // "")"' 2>/dev/null
  else
    printf '%s' "$input" | python3 -c '
import json, shlex, sys
try:
    d = json.load(sys.stdin)
except Exception:
    d = {}
def g(*keys):
    for k in keys:
        v = d.get(k)
        if isinstance(v, str):
            return v
    return ""
print("event=" + shlex.quote(g("hook_event_name", "hookEventName")))
print("sid=" + shlex.quote(g("session_id", "sessionId")))
print("reason=" + shlex.quote(g("reason")))
'
  fi
}

event="" sid="" reason=""
eval "$(parse_input)" || exit 0

# Monotonic across sessions and restarts; herdr drops out-of-order reports.
case "$(date +%N 2>/dev/null)" in
  *N*) seq="$(date +%s)000000000" ;;
  *) seq="$(date +%s%N)" ;;
esac

set -- pane report-agent "$HERDR_PANE_ID" \
  --source "$SOURCE" --agent "$AGENT" --seq "$seq"

case "$event" in
  UserPromptSubmit | PreToolUse | PostToolUse | PostToolUseFailure)
    set -- "$@" --state working
    ;;
  PermissionRequest)
    set -- "$@" --state blocked
    if [ -n "$reason" ]; then
      set -- "$@" --message "$reason"
    fi
    ;;
  SessionStart)
    set -- "$@" --state idle
    if [ -n "$sid" ]; then
      set -- "$@" --agent-session-id "$sid"
    fi
    ;;
  Stop)
    set -- "$@" --state idle
    ;;
  *)
    exit 0
    ;;
esac

if command -v timeout >/dev/null 2>&1; then
  timeout 5 "$HERDR" "$@" >/dev/null 2>&1
else
  "$HERDR" "$@" >/dev/null 2>&1
fi
exit 0
