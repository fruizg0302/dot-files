# Herdr changes, 2026-11-17

Selected configuration for the existing customized Pixel HQ desktop:

- Claude, ZCode, and Droid in the Hire menu and the tab-bar agent menu.
- Matching launcher commands and agent identity detection.
- A graphite/orange Droid robot and blue/violet ZCode fox, with all seven
  animated states. Existing Claude and other pets remain unchanged.
- ZCode working, permission-waiting, idle, and completion reports.

This is not a complete Herdr installation or a backup of all Pixel HQ mods.
It excludes runtime layout state, session stores, histories, telemetry,
generated SDK declarations, backup directories, and the temporary pet gallery.
Copy-on-select was already enabled by default and needed no configuration edit.
The rotation session was diagnostic only and made no changes.

## Menus, pets, and layout

`home/` mirrors selected paths relative to the user's home:

- `programs.json` registers the three launcher commands.
- `company-new-menu/` and `company-tabs/` preserve the two custom mods cloned
  from Herdr's bundled `new-menu` and `tabs` version **0.1.16**.

`patches/agent-pets-and-layout.patch` contains only today's edits to the
pre-existing `company-agents/main.js`, `company-agents/duck.js`, and
`layouts/pixel-hq.json`. The adjacent JSON records SHA-256 hashes of the exact
before and after files. These patches target the existing customized files,
not stock Herdr. They require Pixel HQ's other mods and assets to exist.

Before restoring, back up `programs.json`, both custom menu directories, and
the three patched files. Keep a copy of the original `duck.js` for the pet
regression tests. Merge the `programs` entries into an existing
`~/.config/herdr-app/programs.json` rather than replacing unrelated entries.
Copy the two saved mod directories into `~/.config/herdr-app/mods/`.

From the checkout root, check the patch before applying it:

```sh
DOTFILES="$(pwd)"
APP="$HOME/.config/herdr-app"
git -C "$APP" apply --check "$DOTFILES/herdr/patches/agent-pets-and-layout.patch"
git -C "$APP" apply "$DOTFILES/herdr/patches/agent-pets-and-layout.patch"
```

Do not reapply to an already patched installation. A mismatched base needs
manual review, not forced application. The app hot-reloads these files.

## ZCode activity

`zcode-integration/` preserves the local `herdr-zcode` integration and its
five regression tests. It includes the detection manifest, setup helpers,
legacy socket reporter, and Linux desktop OSC 7501 reporter.

The desktop reporter finds ZCode's terminal through its Linux process
ancestors because ZCode detaches hooks and captures their stdout. Ordinary
hook output would never reach Herdr. Outside Herdr it does nothing.

The current ZCode hook commands point to
`~/src/herdr-zcode/scripts/zcode-state-hook.sh`. Restore the saved integration
at `~/src/herdr-zcode`, or run its setup from another chosen location to
register that location. Back up the existing directory before copying it.
See its [README](zcode-integration/README.md) for setup and event mappings.

Running `sh scripts/setup.sh` from that directory preserves unrelated ZCode
settings, removes the conflicting Claude activity hook, and seeds legacy
agent detection. Existing registered hook paths are not migrated by setup:
if moving the integration, uninstall its old hook registrations first, then
run setup at the new location. Restart ZCode after changing registrations.
Herdr Desktop still needs the saved `programs.json` entry.

## Validation

Requires Node, Python 3, and the existing customized Herdr files. Set
`HERDR_ORIGINAL_PETS` to the unmodified `duck.js` saved before applying the patch:

```sh
export HERDR_APP="$HOME/.config/herdr-app"
export HERDR_ORIGINAL_PETS="/absolute/path/to/original/duck.js"
node --test herdr/tests/*.test.cjs
python3 -m unittest discover -s herdr/zcode-integration/tests -v
```

The Node checks exercise all three Hire commands, cached/refreshed tab menus,
number shortcuts, hidden/unavailable agents, process identity, and every pet
state at heights 26, 34, and 45. Hook tests use pseudo-terminals and a simulated
legacy reporter without sending prompts to a model.
