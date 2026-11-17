# Selected PX13 preferences

Captured on 2026-11-05 from the working Omarchy desktop. `home/` mirrors the
relative paths under the user's home directory. These are selected pending
preferences, not a complete desktop backup or an automatic installer.

## Input

`home/.config/hypr/input.lua` preserves:

- ASUS MD301 sensitivity `0.076` for its Bluetooth and receiver device names.
- KD300 initial repeat delay `500` ms, without overriding the repeat rate.
- Existing keyboard layouts, modifiers, gestures, and touchpad settings.

The user preferred the 500 ms delay after testing 375 ms. The earlier
Bluetooth timing experiment did not help and was reverted; no experimental
Bluetooth transport settings are included.

## Other files

- Hyprland monitor scaling, appearance, and personal bindings.
- The Omarchy bar, dock, plugin preferences, and menu extensions.
- Keyboard-lighting shell completion feedback.
- The Linux-only Neovim Elixir lint override. The macOS Expert setup remains
  in the shared Neovim configuration.

These files retain machine-specific paths and references to existing plugins
and helpers. In particular, `bindings.lua` expects the PX13 ASUS and lighting
Lua files and the `lid-close-suspend` helper to be installed already. Do not
replace an entire configuration directory with this partial snapshot.

Back up the affected live files, inspect the differences, and merge only the
preferences appropriate for the target machine. After a Hyprland change:

```bash
hyprctl reload
hyprctl configerrors
```

Credentials, local deployment hooks, histories, runtime state, backups,
and unchanged upstream plugin source are deliberately excluded.
