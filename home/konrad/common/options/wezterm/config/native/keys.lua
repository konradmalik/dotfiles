local wezterm = require("wezterm")

local act = wezterm.action
return {
    { key = ")", mods = "CTRL", action = act.ResetFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
    { key = "=", mods = "CTRL", action = act.IncreaseFontSize },

    { key = "N", mods = "CTRL", action = act.SpawnTab("DefaultDomain") },
    { key = "n", mods = "SUPER", action = act.SpawnTab("DefaultDomain") },
    { key = "{", mods = "CTRL", action = act.ActivateTabRelative(-1) },
    { key = "{", mods = "SUPER", action = act.ActivateTabRelative(-1) },
    { key = "}", mods = "CTRL", action = act.ActivateTabRelative(1) },
    { key = "}", mods = "SUPER", action = act.ActivateTabRelative(1) },

    { key = "P", mods = "CTRL", action = act.ActivateCommandPalette },
    { key = "p", mods = "SUPER", action = act.ActivateCommandPalette },
    { key = "R", mods = "CTRL", action = act.ShowLauncher },
    { key = "r", mods = "SUPER", action = act.ShowLauncher },

    { key = "V", mods = "CTRL", action = act.PasteFrom("Clipboard") },
    { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
    { key = "Paste", mods = "NONE", action = act.PasteFrom("Clipboard") },

    { key = "C", mods = "CTRL", action = act.CopyTo("Clipboard") },
    { key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
    { key = "Copy", mods = "NONE", action = act.CopyTo("Clipboard") },
}
