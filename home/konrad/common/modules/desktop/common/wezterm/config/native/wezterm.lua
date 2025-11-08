local wezterm = require("wezterm")
local stylix = require("stylix")

local config = wezterm.config_builder()

-- tmp fix until https://github.com/wez/wezterm/issues/5103 is solved in nixpkgs' wezterm version
if os.getenv("XDG_CURRENT_DESKTOP") == "Hyprland" then
    config.enable_wayland = false
    -- tmp fix until https://github.com/wez/wezterm/issues/5990
    config.front_end = "WebGpu"
end

stylix.setup(config)

config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = "NeverPrompt"
config.automatically_reload_config = false
config.audible_bell = "Disabled"

config.window_padding = {
    left = "1cell",
    right = "1cell",
    top = "1cell",
    bottom = "0.5cell",
}

config.window_decorations = "RESIZE | INTEGRATED_BUTTONS"

config.ssh_domains = require("ssh_domains")

config.disable_default_key_bindings = true

config.keys = require("keys")

return config
