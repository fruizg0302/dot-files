#!/bin/sh
# Shared helpers for the ZCode herdr plugin.
# Sourced by setup.sh. Safe to source outside herdr (falls back to defaults).

: "${HERDR_BIN_PATH:=herdr}"
HERDR="$HERDR_BIN_PATH"

# Plugin root: herdr provides this for plugin actions; fall back to this
# script's own location so setup works when invoked directly.
: "${HERDR_PLUGIN_ROOT:=$(cd "$(dirname "$0")/.." && pwd)}"
PLUGIN_ROOT="$HERDR_PLUGIN_ROOT"

# Seed the zcode agent-detection override into herdr's config dirs (once).
# Local overrides always win over bundled/remote manifests. Seeds into the
# plugin config dir (herdr scans it) and the platform dir (always scanned).
ensure_agent_detection() {
  src="$PLUGIN_ROOT/config/agent-detection/zcode.toml"
  [ -f "$src" ] || return 0
  seeded=""
  for base in ${HERDR_PLUGIN_CONFIG_DIR:-} "$HOME/.config/herdr"; do
    [ -n "$base" ] || continue
    dest_dir="$base/agent-detection"
    mkdir -p "$dest_dir"
    dest="$dest_dir/zcode.toml"
    if [ ! -f "$dest" ] || ! cmp -s "$src" "$dest"; then
      cp "$src" "$dest"
    fi
    seeded="$seeded $dest"
  done
  echo "Seeded agent-detection override:$seeded"
}
