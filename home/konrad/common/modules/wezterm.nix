{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.konrad.programs.wezterm;
in
{
  options.konrad.programs.wezterm = {
    enable = mkEnableOption "Enables Wezterm configuration management through home-manager";

    makeDefault = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to make this terminal default by setting TERMINAL env var";
    };

    fontSize = mkOption {
      type = types.number;
      default = config.fontProfiles.monospace.size;
      example = "13.0";
      description = "Font size. If 0, wezterm will set it automatically.";
    };

    fontFamily = mkOption rec {
      type = types.str;
      default = config.fontProfiles.monospace.family;
      example = default;
      description = "Font Family to use. If null, wezterm will set it automatically.";
    };

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.wezterm;
      description = "Package for wezterm. If null, it won't be installed.";
      example = "pkgs.wezterm";
    };

    colorscheme = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = config.colorscheme;
      description = "Colorscheme attrset compatible with nix-colors format.";
      example = "config.colorscheme";
    };
  };

  config =
    let
      colors =
        let
          c = cfg.colorscheme.palette;
        in
        pkgs.writeText "wezterm-colorscheme"
          ''
            scheme: "${cfg.colorscheme.name}"
            author: "${cfg.colorscheme.author}"
            base00: "#${c.base00}"
            base01: "#${c.base01}"
            base02: "#${c.base02}"
            base03: "#${c.base03}"
            base04: "#${c.base04}"
            base05: "#${c.base05}"
            base06: "#${c.base06}"
            base07: "#${c.base07}"
            base08: "#${c.base08}"
            base09: "#${c.base09}"
            base0A: "#${c.base0A}"
            base0B: "#${c.base0B}"
            base0C: "#${c.base0C}"
            base0D: "#${c.base0D}"
            base0E: "#${c.base0E}"
            base0F: "#${c.base0F}"
          '';
      baseConfig = ''
        local wezterm = require('wezterm')

        local config = wezterm.config_builder()

        -- this disables ligatures
        config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
        config.font_size = ${toString cfg.fontSize}
        config.font = wezterm.font('${cfg.fontFamily}')

        colors, metadata = wezterm.color.load_base16_scheme('${colors}')
        config.colors = colors

        config.hide_tab_bar_if_only_one_tab = true
        config.window_close_confirmation = 'NeverPrompt'
        config.automatically_reload_config = false
        config.audible_bell = "Disabled"

        config.window_padding = {
          left = '1cell',
          right = '1cell',
          top = '0.5cell',
          bottom = '0.5cell',
        }

        local ssh_domains = {}
        for host, sshconfig in pairs(wezterm.enumerate_ssh_hosts()) do
          if sshconfig.user ~= 'git' then
            table.insert(ssh_domains, {
              name = host,
              remote_address = host,
              -- set to WezTerm once we install it on the remote hosts
              multiplexing = "None",
              assume_shell = 'Posix',
            })
          end
        end
        config.ssh_domains = ssh_domains

        config.disable_default_key_bindings = true

        local act = wezterm.action
        config.keys = {
            { key = ")",        mods = "CTRL",  action = act.ResetFontSize },
            { key = "-",        mods = "CTRL",  action = act.DecreaseFontSize },
            { key = "=",        mods = "CTRL",  action = act.IncreaseFontSize },

            { key = "Enter",    mods = "ALT",  action = act.ToggleFullScreen },

            { key = "N",        mods = "CTRL",  action = act.SpawnTab("DefaultDomain") },
            { key = "n",        mods = "SUPER",  action = act.SpawnTab("DefaultDomain") },
            { key = "{",        mods = "CTRL",  action = act.ActivateTabRelative(-1) },
            { key = "{",        mods = "SUPER",  action = act.ActivateTabRelative(-1) },
            { key = "}",        mods = "CTRL",  action = act.ActivateTabRelative(1) },
            { key = "}",        mods = "SUPER",  action = act.ActivateTabRelative(1) },

            { key = "P",        mods = "CTRL",  action = act.ActivateCommandPalette },
            { key = "p",        mods = "SUPER",  action = act.ActivateCommandPalette },
            { key = "R",        mods = "CTRL",  action = act.ShowLauncher },
            { key = "r",        mods = "SUPER",  action = act.ShowLauncher },

            { key = "V",        mods = "CTRL",  action = act.PasteFrom("Clipboard") },
            { key = "v",        mods = "SUPER",  action = act.PasteFrom("Clipboard") },
            { key = "Paste",    mods = "NONE",  action = act.PasteFrom("Clipboard") },

            { key = "C",        mods = "CTRL",  action = act.CopyTo("Clipboard") },
            { key = "c",        mods = "SUPER",  action = act.CopyTo("Clipboard") },
            { key = "Copy",     mods = "NONE",  action = act.CopyTo("Clipboard") },
        }

        return config
      '';
    in
    mkIf cfg.enable {
      home = {
        packages = lib.optional (cfg.package != null) cfg.package;
        sessionVariables.TERMINAL = mkIf cfg.makeDefault "wezterm";
      };

      xdg.configFile."wezterm/wezterm.lua".text = baseConfig;
    };
}
