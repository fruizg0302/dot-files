-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

-- Keyboard layout and options.
-- See https://wiki.hypr.land/Configuring/Basics/Variables/#input
-- hl.config({
--   input = {
--     -- Use multiple keyboard layouts and switch between them with Left Alt + Right Alt.
--     kb_layout = "us,dk,eu",
--     kb_options = "compose:caps,shift:both_capslock_cancel,grp:alts_toggle",
--
--     -- Use a specific keyboard variant if needed (e.g. intl for international keyboards).
--     kb_variant = "intl",
--
--     -- Change speed of keyboard repeat.
--     repeat_rate = 40,
--     repeat_delay = 250,
--
--     -- Start with numlock on by default.
--     numlock_by_default = true,
--
--     -- Increase sensitivity for mouse/trackpad (default: 0).
--     sensitivity = 0.35,
--
--     -- Turn off mouse acceleration (default: adaptive).
--     accel_profile = "flat",
--
--     touchpad = {
--       -- Use natural (inverse) scrolling.
--       natural_scroll = true,
--
--       -- Use two-finger clicks for right-click instead of lower-right corner.
--       clickfinger_behavior = true,
--
--       -- Control the speed of your scrolling.
--       scroll_factor = 0.4,
--
--       -- Enable the touchpad while typing.
--       disable_while_typing = false,
--
--       -- Left-click-and-drag with three fingers.
--       drag_3fg = 1,
--     },
--   },
-- })

-- App-specific touchpad scroll speeds.
-- o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
-- o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })

-- Switch workspaces with a four-finger horizontal swipe.
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Gestures/
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })

-- Four fingers up: show window thumbnails for the current workspace.
hl.gesture({ fingers = 4, direction = "up", action = function()
  hl.dispatch(hl.dsp.exec_cmd("omarchy-shell shell toggle local.workspace-overview"))
end })

-- Enable touchpad gestures for moving focus (helpful on scrolling layout).
-- hl.gesture({ fingers = 3, direction = "left", action = function() hl.dispatch(hl.dsp.focus({ direction = "l" })) end })
-- hl.gesture({ fingers = 3, direction = "right", action = function() hl.dispatch(hl.dsp.focus({ direction = "r" })) end })

-- Keyboard: Spanish (Latin American). Deliberate — this is the layout that
-- matches the physical keys on this machine, confirmed by testing es against
-- latam side by side.
--
-- This override is load-bearing, not leftover. Omarchy's default/hypr/input.lua
-- reads XKBLAYOUT from /etc/vconsole.conf, which says "es"; deleting this block
-- silently switches the desktop to Spanish (Spain).
--
-- The TTY (Ctrl+Alt+F3) still follows vconsole and is on "es". To make latam
-- system-wide and retire this block:
--   sudo localectl set-x11-keymap latam pc105 "" terminate:ctrl_alt_bksp
--   sudo localectl set-keymap la-latin1 --no-convert
--
-- kb_options departs from Omarchy's default ("compose:caps,shift:both_capslock_cancel").
-- Omarchy puts Compose on Caps Lock and exiles Caps Lock to both-Shifts-together.
-- Here Caps Lock is just Caps Lock, and Compose moves to the Menu key — which
-- this keyboard has (evdev reports KEY_COMPOSE; there is no separate KEY_MENU).
--
-- Compose is not optional: ~/.XCompose defines <Multi_key> <space> <n> and
-- <space> <e> for name and email, and fcitx5 (omarchy-fcitx5.service) serves
-- them. Dropping compose entirely would silently kill those.
--
-- AltGr is deliberately NOT used for Compose: the latam layout needs it for
-- @ \\ | { } etc., so compose:ralt would cost more than it gains.

-- Invert scroll direction (natural scrolling) on the touchpad.
-- Keep clickfinger behavior and customize the touchpad scroll speed.
hl.config({
  input = {
    kb_layout = "latam,us",
    kb_variant = "",
    kb_options = "compose:menu",
    sensitivity = 0.42,

    touchpad = {
      natural_scroll = true,
      clickfinger_behavior = true,
      scroll_factor = 0.77,
    },
  },
})

-- Built-in PX13 keyboard only: Mac-style modifier row (Super next to the
-- spacebar, Alt where Win was), matching the KD300 in its Mac switch position.
-- swap_lalt_lwin, not swap_alt_win: right Alt must stay AltGr for latam @ \ | { }.
hl.device({
  name = "at-translated-set-2-keyboard",
  kb_layout = "latam,us",
  kb_options = "compose:menu,altwin:swap_lalt_lwin",
})

hl.device({
  name = "proart-keyboard-kd300-keyboard",
  repeat_delay = 500,
})

-- ASUS MD301 mouse: natural scrolling (matching the touchpad), and a bit slower
-- than the global 0.42 sensitivity, which felt too quick for this mouse.
-- Bluetooth and USB-dongle connections report different device names.
for _, name in ipairs({ "asus-md301-mouse", "asustek-proart-mouse-md301-mouse" }) do
  hl.device({ name = name, natural_scroll = true, sensitivity = 0.076 })
end
