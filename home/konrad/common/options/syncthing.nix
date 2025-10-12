{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
with lib;
let
  cfg = config.konrad.services.syncthing;
in
{
  options.konrad.services.syncthing = {
    enable = mkEnableOption "Enables syncthing and its configuration through home-manager";

    install = mkOption {
      type = types.bool;
      default = pkgs.stdenvNoCC.isLinux;
      description = "whether to install syncthing and enable service (on darwin you should install via brew)";
    };

    openFirewallPorts = mkOption {
      type = types.bool;
      default = pkgs.stdenvNoCC.isLinux;
      description = "whether to open required firewall ports";
    };

    openGuiPort = mkOption {
      type = types.bool;
      default = false;
      description = "whether to open GUI port (8384)";
    };

    tray = mkOption {
      type = types.bool;
      default = false;
      description = "whether to enable tray icon support";
    };
  };
  config = mkIf cfg.enable {
    warnings =
      if
        (
          !builtins.elem 22000 osConfig.networking.firewall.allowedUDPPorts
          || !builtins.elem 21027 osConfig.networking.firewall.allowedUDPPorts
          || !builtins.elem 22000 osConfig.networking.firewall.allowedTCPPorts
        )
      then
        [ "required ports are not open in the firewall, you may have problems connecting with syncthing" ]
      else
        [ ];

    services.syncthing = {
      enable = cfg.install;
      tray.enable = cfg.tray;
    };
  };
}
