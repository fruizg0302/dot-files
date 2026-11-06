# Omarchy display recovery guard

User-local workaround for the lock-screen/display-power loop observed after
suspend on the PX13 with an external HDMI monitor. Tested against Omarchy
4.5.0-3 and its Lua-based Hyprland build. No packaged files are modified;
locking and suspend remain enabled.

The two commands in `bin/` wrap the packaged clamshell and modeless-monitor
recovery commands. They defer recovery while a real enabled display has DPMS
off. They also leave a locked, closed-lid session alone when no real output
remains, instead of removing its clamshell flag and reloading the monitors.
Unknown compositor replies defer recovery rather than changing display state.
Lid-open and unlocked-session recovery still use Omarchy's implementations.

The Hyprland override puts this directory's `bin/` first on the graphical
session's PATH. Only those two commands are overridden; other commands still
resolve normally. Recovery delegates to the installed Omarchy scripts, so
package updates remain available rather than being copied into this checkout.

## Restore

Requires Omarchy, Bash, jq, and GNU coreutils (`timeout`). Back up
`~/.config/hypr/autostart.lua`, any existing `display-guard.lua`, and any
existing `~/.local/lib/omarchy-display-guard` directory first.

From the root of this dotfiles checkout:

```sh
mkdir -p "$HOME/.local/lib/omarchy-display-guard" "$HOME/.config/hypr"
cp -a omarchy/display-guard/. "$HOME/.local/lib/omarchy-display-guard/"
cp omarchy/hypr/display-guard.lua "$HOME/.config/hypr/display-guard.lua"
```

Add this line to `~/.config/hypr/autostart.lua`, preserving other startup
settings. Load it after the Omarchy defaults initialize `hl`:

```lua
dofile(os.getenv("HOME") .. "/.config/hypr/display-guard.lua")
```

If the equivalent display-guard PATH block is already present inline, replace
that block with the line above rather than keeping both.

```sh
hyprctl reload
hyprctl configerrors
```

Log out and back in so the existing monitor watcher and shell inherit the
guarded PATH. A configuration reload alone does not update the environments of
already running processes.

## Verification

From the checkout root on an Omarchy machine with Python 3 and ShellCheck:

```sh
python3 omarchy/display-guard/tests/test_recovery.py -v
shellcheck omarchy/display-guard/recovery omarchy/display-guard/bin/*
luac -p omarchy/hypr/display-guard.lua
hyprctl configerrors
```

The 12 tests use a temporary HOME and simulated compositor commands while
exercising the installed Omarchy recovery scripts. They do not lock, blank, or
suspend the real desktop. Repeat them after Omarchy updates, since the wrapper
depends on the recovery commands' interfaces and exit codes.

A manual suspend/resume test with the normal external-monitor setup is still
needed to confirm the hardware symptom is resolved. Also check that opening
the lid restores the internal display.

## Disable

Rename `~/.local/lib/omarchy-display-guard/bin` to `bin.disabled` inside the
same directory. Existing PATH entries then fall through to Omarchy's packaged
recovery commands, including in the running watcher. Remove the `dofile` line
(or original inline PATH block) from `~/.config/hypr/autostart.lua`, then reload
Hyprland to clean up the persistent configuration.
Do not restore a backup over subsequent unrelated configuration changes.
