# Omarchy desktop fixes

Personal overrides for Omarchy 4's Lua-based Hyprland configuration.

- The dock matches custom launchers using `StartupWMClass`, so Ghostty and Zed
  windows stay grouped under their pinned icons when minimized or restored.
- Super+Tab previews the next window while Super is held and focuses it when
  Super is released, including quick taps. Repeated taps visit a stable list and
  wrap around; Super+Shift+Tab moves backward.
- Press and release events share the compositor event socket. A timer checks
  the actual Super key state during each gesture so a missed release event
  cannot leave the preview open.

These files preserve the working configuration. The plugin patches target:

| Plugin | Upstream base commit |
| --- | --- |
| [rosakodu/omarchy-dock](https://github.com/rosakodu/omarchy-dock) | `a1e70d15c468710d45e02238680e6cb95d1aea2d` |
| [piyush97/omaswitch](https://github.com/piyush97/omaswitch) | `0afaa7fe83a93db16df5dcee1dd0ca8015a37d6b` |

The patches include regression tests. Upstream MIT notices are in `licenses/`.

## Restore

Install and enable both plugins first. Back up the affected plugin files,
`~/.config/hypr/bindings.lua`, and the two custom desktop entries before applying
these overrides. The commands below assume the plugins are checked out at the
base commits above; on newer versions, inspect any patch conflicts first.
An already patched installation does not need these steps again.

Run from the root of this dotfiles checkout:

```bash
DOTFILES="$(pwd)"
PLUGINS="$HOME/.config/omarchy/plugins"

git -C "$PLUGINS/rosakodu.dock" apply --check "$DOTFILES/omarchy/patches/rosakodu.dock-window-grouping.patch"
git -C "$PLUGINS/rosakodu.dock" apply "$DOTFILES/omarchy/patches/rosakodu.dock-window-grouping.patch"
git -C "$PLUGINS/piyush.omaswitch" apply --check "$DOTFILES/omarchy/patches/piyush.omaswitch-super-tab.patch"
git -C "$PLUGINS/piyush.omaswitch" apply "$DOTFILES/omarchy/patches/piyush.omaswitch-super-tab.patch"
```

The launcher patch assumes `local-ghostty.desktop` and `local-zed.desktop`
already exist in `~/.local/share/applications`. It preserves their commands and
custom icons:

```bash
patch --dry-run -p1 -d "$HOME/.local/share/applications" < "$DOTFILES/omarchy/patches/dock-launchers.patch"
patch -p1 -d "$HOME/.local/share/applications" < "$DOTFILES/omarchy/patches/dock-launchers.patch"
update-desktop-database "$HOME/.local/share/applications"
```

For differently named launchers, add the relevant keys inside `[Desktop Entry]`:

| Application | Desktop entry keys |
| --- | --- |
| Ghostty | `StartupWMClass=com.mitchellh.ghostty` and `Categories=System;TerminalEmulator;` |
| Zed | `StartupWMClass=dev.zed.Zed` |

Copy `hypr/super-tab.lua` to `~/.config/hypr/super-tab.lua`. In
`~/.config/hypr/bindings.lua`, replace the existing OmaSwitch/Super+Tab block with
the following line, keeping the other personal bindings:

```lua
dofile(os.getenv("HOME") .. "/.config/hypr/super-tab.lua")
```

Load it only once, after Omarchy has initialized `hl` and `o`. This override
requires Omarchy's Lua Hyprland build and OmaSwitch's `keepLoaded` manifest
setting. Reload and check for errors, then restart the shell to load the plugin
and desktop entry changes:

```bash
hyprctl reload
hyprctl configerrors
omarchy restart shell
```

Plugin updates may require reapplying or adapting these patches.

## Validation

After applying the patches, run:

```bash
node "$PLUGINS/piyush.omaswitch/test_model.js"
QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=generic /usr/lib/qt6/bin/qmltestrunner \
  -input "$PLUGINS/rosakodu.dock/tests/tst_DockMatcher.qml"
luac -p "$DOTFILES/omarchy/hypr/super-tab.lua"
```

On the desktop, hold Super+Tab to preview, release Super to focus, then tap
through a complete cycle in both directions. Minimize and restore multiple
Ghostty or Zed windows and check that each application keeps one dock icon.
