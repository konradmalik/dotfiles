{ config, lib, pkgs, ... }:
with lib;
let cfg = config.konrad.programs.desktop;
in {
  options.konrad.programs.desktop = {
    enable = mkEnableOption "Enables Desktop apps configuration through home-manager";
  };

  config = mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs;[
      (nerdfonts.override { fonts = [ "Hack" "Meslo" ]; })
    ];

    konrad.programs.alacritty.enable = mkDefault true;
  };
}
