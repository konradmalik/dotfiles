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

config.window_background_opacity = 0.9
config.macos_window_background_blur = 30
config.window_decorations = "RESIZE | INTEGRATED_BUTTONS"

config.ssh_domains = require("ssh_domains")

config.disable_default_key_bindings = true

config.keys = require("keys")

return config
