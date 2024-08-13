local wezterm = require("wezterm")
local fonts = require("fonts")

local config = wezterm.config_builder()

fonts.setup(config)

config.colors = require("colors")

config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = "NeverPrompt"
config.automatically_reload_config = false
config.audible_bell = "Disabled"

config.window_padding = {
    left = "1cell",
    right = "1cell",
    top = "0.5cell",
    bottom = "0.5cell",
}

local ssh_domains = {}
for host, sshconfig in pairs(wezterm.enumerate_ssh_hosts()) do
    if sshconfig.user ~= "git" then
        table.insert(ssh_domains, {
            name = host,
            remote_address = host,
            -- set to WezTerm once we install it on the remote hosts
            multiplexing = "None",
            assume_shell = "Posix",
        })
    end
end
config.ssh_domains = ssh_domains

config.disable_default_key_bindings = true

local act = wezterm.action
config.keys = {
    { key = ")", mods = "CTRL", action = act.ResetFontSize },
    { key = "-", mods = "CTRL", action = act.DecreaseFontSize },
    { key = "=", mods = "CTRL", action = act.IncreaseFontSize },

    { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },

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

return config
