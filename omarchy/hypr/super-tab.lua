-- OmaSwitch: Super+Tab advances through a stable list; Super release confirms.
-- Previously these used separate summon/confirm processes that could race on
-- quick taps. Native events reach the switcher in compositor input order.
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
local omaswitch_active = false
local omaswitch_release_timer
local function omaswitch_confirm()
  if not omaswitch_active then return end
  omaswitch_active = false
  omaswitch_release_timer:set_enabled(false)
  hl.dispatch(hl.dsp.event("omaswitch,confirm"))
end

-- A focused overlay or another chord can swallow a modifier-release binding.
-- Check the compositor's actual key state only during a switching gesture.
-- is_key_down uses case-sensitive XKB names (unlike bind parsing).
omaswitch_release_timer = hl.timer(function()
  if omaswitch_active and not hl.is_key_down("Super_L") and not hl.is_key_down("Super_R") then
    omaswitch_confirm()
  end
end, { timeout = 16, type = "repeat" })
omaswitch_release_timer:set_enabled(false)

local function omaswitch_step(direction)
  return function()
    omaswitch_active = true
    omaswitch_release_timer:set_enabled(true)
    hl.dispatch(hl.dsp.event("omaswitch," .. direction))
  end
end
o.bind("SUPER + TAB", "OmaSwitch next app", omaswitch_step("next"))
o.bind("SUPER + SHIFT + TAB", "OmaSwitch previous app", omaswitch_step("previous"))

-- Confirm the preview on Super release, including while its overlay has focus.
for _, key in ipairs({ "SUPER_L", "SUPER_R" }) do
  hl.unbind(key)
  o.bind(key, "Confirm OmaSwitch on Super release", omaswitch_confirm, {
    release = true, ignore_mods = true, locked = true, non_consuming = true,
    transparent = true,
  })
end
