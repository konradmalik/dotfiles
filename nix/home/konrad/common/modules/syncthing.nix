{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.konrad.programs.syncthing;
  sharedConfig = {
    services.syncthing = {
      enable = cfg.install;
      tray.enable = cfg.tray;
    };
  };
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
  config = mkIf cfg.enable (lib.mkMerge [
    sharedConfig
    (mkIf pkgs.stdenvNoCC.isDarwin {
      home.file."/Library/Application Support/Syncthing/config.xml".source = config.lib.file.mkOutOfStoreSymlink ./../../../../../files/syncthing/macos.xml;
    })
    (mkIf pkgs.stdenvNoCC.isLinux {
      xdg.configFile."syncthing/config.xml".source = config.lib.file.mkOutOfStoreSymlink ./../../../../../files/syncthing/linux.xml;
    })
  ]);
}
