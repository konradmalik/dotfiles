{ config, lib, pkgs, ... }:
with lib;
let cfg = config.konrad.programs.alacritty;
in {
  options.konrad.programs.alacritty = {
    enable = mkEnableOption "Enables Alacritty configuration management through home-manager";

    fontSize = mkOption {
      type = types.number;
      default = 0;
      example = "13.0";
      description = "Font size. If default, alacritty will set it automatically.";
    };

    fontFamily = mkOption rec {
      type = types.str;
      default = "Hack Nerd Font";
      example = default;
      description = "Font Family to use. If null, alacritty will set it automatically.";
    };
  };

  config =
    let
      baseYmls = map builtins.readFile [
        "${pkgs.dotfiles}/alacritty/catppuccin.yml"
        # important that alacritty is last, and that font is the last section there
        # makes it simple to lib.mkAfter font size per machine
        "${pkgs.dotfiles}/alacritty/alacritty.yml"
      ];
    in
    mkIf cfg.enable {
      xdg.configFile."alacritty/alacritty.yml".text = strings.concatStringsSep "\n" ([
        (strings.optionalString
          (cfg.fontFamily != null)
          "fontfamily: &fontfamily \"${cfg.fontFamily}\"")
      ] ++ baseYmls ++ [
        (strings.optionalString
          (cfg.fontSize != 0)
          "  size: ${strings.floatToString cfg.fontSize}")
      ]);
    };
}
