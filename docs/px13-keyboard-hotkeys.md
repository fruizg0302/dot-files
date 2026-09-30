# ASUS ProArt PX13 keyboard hotkeys

Setup recorded on 2026-09-29 for the ProArt PX13 HN7306EAC running
Omarchy with kernel `7.2.5-3-omarchy-bore`.

The top row should start in hotkey mode, so its actions work without holding
Fn. F8 cycles keyboard lighting effects, and Shift+F8 cycles backward.
Fn+Esc still switches between hotkeys and standard F1–F12 keys.

This document records the machine-specific system settings. The current
Omarchy configuration source is
[`fruizg0302/omarchy-config`](https://github.com/fruizg0302/omarchy-config);
the old `omarchy/` snapshot in dot-files is not the restore source.

## Why F8 needed a hardware remap

Hyprland already bound F8 to keyboard lighting, but the physical key in hotkey
mode emitted the ASUS radio-toggle event instead. NetworkManager recorded
Wi-Fi being disabled and enabled by the radio killswitch. The ASUS WMI input
device has a kernel `rfkill` handler, so a desktop binding alone did not
prevent that toggle.

The installed driver mapped ASUS scan code `0x88` to `KEY_RFKILL` (247).
The local hardware database override changes it to `KEY_F8` (66), allowing
the existing desktop binding to handle it.

File: `/etc/udev/hwdb.d/90-px13-f8-effects.hwdb`

```text
# ASUS ProArt PX13: send the radio hotkey to the existing F8 lighting binding.
evdev:name:Asus WMI hotkeys:dmi:*:svnASUS:pnProArtPX13HN7306EAC:*
 KEYBOARD_KEY_88=f8
```

This match is specific to the HN7306EAC model and ASUS WMI hotkey device.
After installing the file, apply it as root:

```bash
sudo systemd-hwdb update
HOTKEY_DEVICE=/dev/input/by-path/platform-asus-nb-wmi-event
sudo udevadm trigger --action=change "$HOTKEY_DEVICE"
sudo udevadm settle
udevadm info --query=property --name="$HOTKEY_DEVICE" | rg KEYBOARD_KEY_88
```

Expected property: `KEYBOARD_KEY_88=f8`. The event device was `event15` during
setup; use the stable by-path name instead of assuming that number persists.

## Desktop lighting bindings

The live `~/.config/hypr/keyboard-glow.lua` contains:

```lua
hl.unbind("F8")
hl.unbind("SHIFT + F8")
o.bind("F8", "Keyboard lighting next effect", "~/.local/bin/asus-hotkey effect next", { locked = true })
o.bind("SHIFT + F8", "Keyboard lighting previous effect", "~/.local/bin/asus-hotkey effect prev", { locked = true })
```

These require the existing keyboard-glow service, `glow` command, and
`asus-hotkey` helper from the PX13 configuration. The helper turns lighting
on at medium brightness when it is off before changing the effect. Back up
the Lua configuration before changing it, and validate any edits with
`hyprctl reload` followed by `hyprctl configerrors`.

## Make hotkey mode the boot default

The ASUS driver starts with `fnlock_default=1`, selecting standard function
keys. Set it to zero to select hotkey mode when the driver initializes.

File: `/etc/modprobe.d/px13-fn-hotkeys.conf`

```text
# Default ASUS top row to hotkey actions without holding Fn.
# Fn+Esc can still toggle to standard F1-F12 mode.
options asus_wmi fnlock_default=0
```

On this Omarchy installation, rebuild the Limine boot images after installing
or changing that file:

```bash
sudo limine-mkinitcpio
```

Reboot when convenient. There is no need to unload the active ASUS driver.
After reboot, verify:

```bash
cat /sys/module/asus_wmi/parameters/fnlock_default
```

Expected value: `N`. Confirm that F8 cycles lighting without holding Fn and
that Fn+Esc still switches modes.

## Verification status

- The live keymap was verified to map scan code `0x88` to keycode 66.
- Udev reported `KEYBOARD_KEY_88=f8`, and both Hyprland F8 bindings were active.
- `modprobe --showconfig` reported `options asus_wmi fnlock_default=0`.
- Boot images for linux, linux-omarchy-bore, and linux-omarchy rebuilt successfully.
- Physical-key behavior after the remap and the boot default after reboot still
  require a manual check; these were not verified during setup.

## Rollback

Remove the two local override files, then rebuild the hardware database and
boot images. Reboot to restore the driver's original radio-key mapping and
Fn-lock default. Removing the hwdb file alone does not reset the already
loaded keymap. The existing Hyprland F8 lighting bindings can remain.

Driver references:
[ASUS WMI radio keymap](https://github.com/torvalds/linux/blob/master/drivers/platform/x86/asus-nb-wmi.c),
[ASUS Fn-lock initialization](https://github.com/torvalds/linux/blob/master/drivers/platform/x86/asus-wmi.c),
[systemd keyboard hardware database format](https://github.com/systemd/systemd/blob/main/hwdb.d/60-keyboard.hwdb).
