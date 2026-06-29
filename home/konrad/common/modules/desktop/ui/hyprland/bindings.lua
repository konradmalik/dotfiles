-- Keyboard layout toggle behavior
hl.bind("SUPER + c", hl.dsp.exec_cmd("hyprctl keyword input:kb_options grp:shifts_toggle,ctrl:nocaps,lv3:lalt_switch"))
hl.bind("SUPER + SHIFT + c", hl.dsp.exec_cmd("hyprctl keyword input:kb_options grp:shifts_toggle,ctrl:nocaps"))

-- Program bindings
hl.bind("SUPER + return", hl.dsp.exec_cmd("$TERMINAL"))
hl.bind("SUPER + w", hl.dsp.exec_cmd("makoctl dismiss"))
hl.bind("SUPER + b", hl.dsp.exec_cmd("$BROWSER"))
hl.bind("SUPER + space", hl.dsp.exec_cmd("fuzzel"))

-- Screenshots
-- NOTE: killall is useful for occasional freezes of hyprpicker
-- just try to screenshot again and it should unfreeze
hl.bind("SUPER + p", hl.dsp.exec_cmd("killall hyprpicker ; hyprshot --freeze --mode region --output /tmp/screenshots"))
hl.bind("SUPER + SHIFT + p", hl.dsp.exec_cmd("killall hyprpicker ; hyprshot --freeze --raw --mode region --clipboard-only | swappy -f -"))

-- Window manager controls
hl.bind("SUPER + SHIFT + q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + e", hl.dsp.exit())
hl.bind("SUPER + f", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind("SUPER + SHIFT + f", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind("SUPER + SHIFT + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + minus", hl.dsp.layout("splitratio -0.25"))
hl.bind("SUPER + SHIFT + minus", hl.dsp.layout("splitratio -0.3333333"))
hl.bind("SUPER + equal", hl.dsp.layout("splitratio 0.25"))
hl.bind("SUPER + SHIFT + equal", hl.dsp.layout("splitratio 0.3333333"))

-- dwindle
hl.bind("SUPER + s", hl.dsp.window.pseudo())
hl.bind("SUPER + g", hl.dsp.group.toggle())
hl.bind("SUPER + apostrophe", hl.dsp.group.next())
hl.bind("SUPER + SHIFT + apostrophe", hl.dsp.group.prev())

-- Cycle / swap windows
hl.bind("SUPER + tab", hl.dsp.window.cycle_next({ next = true }))
hl.bind("SUPER + SHIFT + tab", hl.dsp.window.cycle_next({ prev = true }))
hl.bind("SUPER + CTRL + tab", hl.dsp.window.swap({ next = true }))
hl.bind("SUPER + CTRL + SHIFT + tab", hl.dsp.window.swap({ prev = true }))

-- Focus / move windows across directions and monitors
local function moveWorkspaceToMonitor(monitor)
  return function()
    local ws = hl.get_active_workspace()
    if not ws then return end
    hl.dispatch(hl.dsp.workspace.move({ workspace = ws.id, monitor = monitor }))
  end
end

local directions = {
  { keys = { "left", "h" },  dir = "l", word = "left" },
  { keys = { "right", "l" }, dir = "r", word = "right" },
  { keys = { "up", "k" },    dir = "u", word = "up" },
  { keys = { "down", "j" },  dir = "d", word = "down" },
}

for _, d in ipairs(directions) do
  for _, key in ipairs(d.keys) do
    hl.bind("SUPER + " .. key, hl.dsp.focus({ direction = d.word }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = d.dir }))
    hl.bind("SUPER + CTRL + " .. key, hl.dsp.focus({ monitor = d.dir }))
    hl.bind("SUPER + CTRL + SHIFT + " .. key, hl.dsp.window.move({ monitor = d.dir }))
    hl.bind("SUPER + ALT + " .. key, moveWorkspaceToMonitor(d.dir))
  end
end

-- Special workspace
hl.bind("SUPER + u", hl.dsp.workspace.toggle_special(""))
hl.bind("SUPER + SHIFT + u", hl.dsp.window.move({ workspace = "special" }))

-- Workspaces
local workspaceKeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
for i, key in ipairs(workspaceKeys) do
  local ws = string.format("%02d", i)
  hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = ws }))
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws, follow = false }))
end

-- Mouse bindings
hl.bind("SUPER + mouse:272", hl.dsp.window.drag())
hl.bind("SUPER + mouse:273", hl.dsp.window.resize())

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })

-- Media control
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })
