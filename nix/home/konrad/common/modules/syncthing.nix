{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.konrad.programs.syncthing;
in
{
  options.konrad.programs.syncthing = {
    enable = mkEnableOption "Enables syncthing and its configuration through home-manager";

    install = mkOption {
      type = types.bool;
      default = pkgs.stdenvNoCC.isLinux;
      description = "whether to install syncthing and enable service (on darwin you should install via brew)";
    };

    tray = mkOption {
      type = types.bool;
      default = false;
      description = "whether to enable tray icon support";
    };
  };
  config = mkIf cfg.enable {
    services.syncthing = {
      enable = cfg.install;
      tray.enable = cfg.tray;
    };
  };
}
