-- Change the default Omarchy look'n'feel.

-- Keep a small gap between tiled windows.
-- Keep a 2 px gap below the top bar and above the dock.
hl.config({
  general = {
    gaps_in = 2,
    gaps_out = { top = 2, right = 1, bottom = 2, left = 1 },
  },
})

-- Keep workspace changes easy to follow with a horizontal slide (850 ms).
hl.animation({ leaf = "workspaces", enabled = true, speed = 8.5, bezier = "easeOutQuint", style = "slide" })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
hl.config({
  animations = {
    enabled = true,
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })
-- Glass background for the ODock plugin.
hl.layer_rule({ match = { namespace = "^omarchy-odock$" }, blur = true, ignore_alpha = 0.3 })

-- >>> omaland managed block >>>
-- Written by Omaland. Safe to hand-edit: Omaland re-reads this block
-- every time it opens, and only ever rewrites what's between the fences.
hl.config({
  decoration = {
    rounding = 5,
  },

  general = {
    snap = {
      enabled = true,
    },
  },
})
-- <<< omaland managed block <<<

-- Opt another application in to Omarchy's standard transparency.
-- Find its class with: hyprctl clients
-- o.transparent_window("my-app")
-- o.transparent_window("my-app", "0.9 0.85") -- Custom active/inactive opacity.
