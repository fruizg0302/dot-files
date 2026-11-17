-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")

-- Upstream OmaSwitch confirms the selection when Super is released.
o.rebind("SUPER + TAB", "OmaSwitch next app", "omarchy-shell shell summon piyush.omaswitch '{\"mode\":\"cycle\",\"direction\":1}'")
o.rebind("SUPER + SHIFT + TAB", "OmaSwitch previous app", "omarchy-shell shell summon piyush.omaswitch '{\"mode\":\"cycle\",\"direction\":-1}'")

dofile(os.getenv("HOME") .. "/.config/hypr/asus-bindings.lua")

dofile(os.getenv("HOME") .. "/.config/hypr/keyboard-glow.lua")

-- Wayscriber: draw over the desktop with the touchscreen stylus.
hl.unbind("F12")
o.bind("F12", "Toggle screen annotation", "wayscriber --daemon-toggle", { locked = true })

-- MD301 thumb buttons switch workspaces like the four-finger swipe. Global, so
-- apps (browsers) no longer receive back/forward from these buttons.
o.bind("mouse:275", "Previous workspace (mouse back)", hl.dsp.focus({ workspace = "r-1" }))
o.bind("mouse:276", "Next workspace (mouse forward)", hl.dsp.focus({ workspace = "r+1" }))

-- Suspend a closed lid on a charger unless an external monitor is connected.
o.rebind("switch:on:Lid Switch", nil, "lid-close-suspend", { locked = true })
