-- Laptop panel profiles from the konrad.hyprland.monitors Nix module
local cfg = require("monitors.config")

local M = {}

-- a real monitor other than the panel; virtual outputs (headless ones,
-- hyprland's FALLBACK) have no EDID, so no description
local function is_external(m) return m.name ~= cfg.panel and m.description ~= "" end

local function external()
  for _, m in ipairs(hl.get_monitors()) do
    if is_external(m) then return m.name end
  end
end

-- hyprland repaints only the mirrored picture, never the bars around it, so they
-- keep stale pixels;
-- workaround -> while mirroring every frame is repainted in full
local tracking

function M.apply(name)
  local profile = assert(cfg.profiles[name], "no monitor profile " .. name)
  -- hl.monitor merges into the panel's previous rule
  -- so set every field for profile to overwrite the previous one
  local rule =
    { output = cfg.panel, disabled = false, mirror = "", mode = "preferred", position = "auto-left", scale = 1 }
  for k, v in pairs(profile) do
    rule[k] = v
  end
  if rule.mirror == "external" then rule.mirror = external() or "" end
  hl.config({ debug = { damage_tracking = rule.mirror ~= "" and 0 or tracking } })
  hl.monitor(rule)
end

local function auto() M.apply(external() and cfg.connected or cfg.disconnected) end

-- the panel coming and going is a profile's doing, virtual outputs aren't plugs
local function on_plug(m)
  if is_external(m) then auto() end
end

hl.on("monitor.added", on_plug)
hl.on("monitor.removed", on_plug)
-- right away, so the panel's rule exists before the rest of the config (the
-- fallback monitor rule) loads; otherwise a reload briefly turns the panel on
auto()
-- and again once the whole config has run, at startup and on every reload, so the
-- configured settings are known and nothing loaded after this file overrides it
hl.on("config.reloaded", function()
  tracking = hl.get_config("debug.damage_tracking")
  auto()
end)

return M
