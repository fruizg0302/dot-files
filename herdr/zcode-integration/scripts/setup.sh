#!/bin/sh
# Install/uninstall the ZCode <-> Herdr integration.
# 1. Seeds the agent-detection override so Herdr recognizes the zcode-cli process.
# 2. Registers state-reporting hooks in the ZCode user config.
# 3. Removes the claude integration hook herdr installs into ZCode configs;
#    it labels ZCode panes as "claude" and double-reports the session.
#
# Usage: setup.sh [--uninstall]
set -eu
. "$(dirname "$0")/common.sh"

ZCODE_CONFIG="${ZCODE_CONFIG:-$HOME/.zcode/cli/config.json}"
HOOK_MARKER="zcode-state-hook.sh"
CLAUDE_HOOK_MARKER="herdr-agent-state.sh"

uninstall_hooks() {
  [ -f "$ZCODE_CONFIG" ] || return 0
  # "state-hook.sh" also matches "zcode-state-hook.sh" (older installs)
  grep -q "state-hook.sh" "$ZCODE_CONFIG" || { echo "No ZCode hooks found."; return 0; }
  backup="$ZCODE_CONFIG.bak.herdr-zcode-$(date +%Y%m%d-%H%M%S)"
  cp "$ZCODE_CONFIG" "$backup"
  python3 - "$ZCODE_CONFIG" <<'PY'
import json, sys

path = sys.argv[1]
with open(path) as f:
    cfg = json.load(f)
events = cfg.get("hooks", {}).get("events", {})
removed = 0
for name in list(events):
    keep = [
        entry for entry in events[name]
        if "state-hook.sh" not in json.dumps(entry.get("hooks", []))
    ]
    removed += len(events[name]) - len(keep)
    if keep:
        events[name] = keep
    else:
        del events[name]
with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")
print(f"Removed {removed} hook entr(ies).")
PY
  echo "Removed ZCode hooks (backup: $backup)"
}

install_hooks() {
  if [ ! -f "$ZCODE_CONFIG" ]; then
    echo "No ZCode config at $ZCODE_CONFIG; skipping hook registration." >&2
    return 0
  fi
  if grep -q "$HOOK_MARKER" "$ZCODE_CONFIG"; then
    echo "ZCode hooks already registered."
    return 0
  fi
  backup="$ZCODE_CONFIG.bak.herdr-zcode-$(date +%Y%m%d-%H%M%S)"
  cp "$ZCODE_CONFIG" "$backup"
  HOOK_MARKER="$HOOK_MARKER" \
    CLAUDE_HOOK_MARKER="$CLAUDE_HOOK_MARKER" \
    HOOK_COMMAND="bash '$PLUGIN_ROOT/scripts/zcode-state-hook.sh'" \
    python3 - "$ZCODE_CONFIG" <<'PY'
import json, os, sys

path = sys.argv[1]
hook_marker = os.environ["HOOK_MARKER"]
claude_marker = os.environ["CLAUDE_HOOK_MARKER"]
command = os.environ["HOOK_COMMAND"]
events_to_register = [
    "SessionStart", "UserPromptSubmit", "PreToolUse", "PermissionRequest",
    "PostToolUse", "PostToolUseFailure", "Stop",
]

with open(path) as f:
    cfg = json.load(f)

hooks = cfg.setdefault("hooks", {})
if "enabled" not in hooks:
    hooks["enabled"] = True
events = hooks.setdefault("events", {})
removed_claude = 0

for name in list(events):
    keep = []
    for entry in events[name]:
        entries_json = json.dumps(entry.get("hooks", []))
        if hook_marker in entries_json:
            continue  # never duplicate our own hooks
        if claude_marker in entries_json:
            removed_claude += 1  # herdr's claude hook mislabels ZCode panes
            continue
        keep.append(entry)
    if keep:
        events[name] = keep
    else:
        del events[name]

for name in events_to_register:
    events.setdefault(name, []).append({
        "matcher": "*",
        "hooks": [{
            "type": "command",
            "async": True,
            "command": command,
            "timeout": 10,
        }],
    })

with open(path, "w") as f:
    json.dump(cfg, f, indent=2)
    f.write("\n")

if removed_claude:
    print(f"Removed {removed_claude} claude integration hook(s) that mislabel ZCode panes.")
PY
  echo "Registered ZCode hooks (backup: $backup)"
  if [ "$(python3 -c "import json;print(json.load(open('$ZCODE_CONFIG'))['hooks'].get('enabled', True))")" != "True" ]; then
    echo "Warning: hooks.enabled is false in $ZCODE_CONFIG; state reporting will not fire." >&2
  fi
}

case "${1:-}" in
  --uninstall)
    uninstall_hooks
    echo "ZCode <-> Herdr integration removed. The agent-detection override was left in place."
    ;;
  --help | -h)
    echo "Usage: setup.sh [--uninstall]"
    echo "  (no args)  Seed detection override and register ZCode hooks"
    echo "  --uninstall Remove the ZCode hooks (detection override stays)"
    ;;
  *)
    ensure_agent_detection
    install_hooks
    "$HERDR" server reload-agent-manifests 2>/dev/null ||
      echo "Note: restart Herdr (or run: herdr server reload-agent-manifests) to apply the detection override." >&2
    echo "ZCode <-> Herdr integration ready. Restart any running ZCode session to start reporting."
    ;;
esac
