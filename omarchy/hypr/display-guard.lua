-- Keep automatic monitor recovery from undoing lock-screen display blanking.
local display_guard_bin = os.getenv("HOME") .. "/.local/lib/omarchy-display-guard/bin"
local omarchy_bin = (os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/bin"
local display_guard_path = { display_guard_bin, omarchy_bin }
for entry in (os.getenv("PATH") or "/usr/local/bin:/usr/bin"):gmatch("[^:]+") do
  if entry ~= display_guard_bin and entry ~= omarchy_bin then
    table.insert(display_guard_path, entry)
  end
end
hl.env("PATH", table.concat(display_guard_path, ":"))
