# Quiet Droid startup

The 2026-11-17 change adds `"suppressOutput": true` to the Superpowers
SessionStart hook's Claude-compatible JSON branch, which Droid uses.
It retains `hookSpecificOutput.additionalContext` and the injected skill
instructions. No Factory credentials or complete settings files are saved.

`patches/superpowers-quiet-startup.patch` targets Superpowers commit
`22f0b463e7a5e579904dd6211a520321035526f7`, installed on this machine at:

```text
~/.factory/plugins/cache/superpowers-b225390a8984/superpowers-b225390a8984/22f0b463e7a5
```

Plugin updates can replace this cache and remove the customization. Locate
the active plugin version and inspect it before reapplying; do not apply the
patch blindly to a newer version.

Back up `hooks/session-start`, then run from this dotfiles checkout root:

```sh
DOTFILES="$(pwd)"
PLUGIN="$HOME/.factory/plugins/cache/superpowers-b225390a8984/superpowers-b225390a8984/22f0b463e7a5"
git -C "$PLUGIN" apply --check "$DOTFILES/factory/patches/superpowers-quiet-startup.patch"
git -C "$PLUGIN" apply "$DOTFILES/factory/patches/superpowers-quiet-startup.patch"
bash -n "$PLUGIN/hooks/session-start"
CLAUDE_PLUGIN_ROOT="$PLUGIN" bash "$PLUGIN/hooks/session-start" |
  jq -e '.suppressOutput == true and (.hookSpecificOutput.additionalContext | length > 0)'
```

Do not reapply to an already patched hook. Restart Droid to check the startup
display interactively; syntax and JSON checks do not prove that UI behavior.
