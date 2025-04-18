{ config, lib, ... }:
with lib;
let
  cfg = config.konrad.services.syncthing;
in
{
  # used on 'server' machines for backup mostly. For interactive stuff we use home-manager service
  options.konrad.services.syncthing = {
    enable = mkEnableOption "Enables syncthing and its configuration through nixos (uses home-manager as well)";

    user = mkOption {
      type = types.str;
      description = "user name";
    };

    bidirectional = mkOption {
      type = types.bool;
      description = "whether to use receiveonly or sendreceive mode";
    };
  };
  config =
    let
      homeDirectory = "${config.home-manager.users.${cfg.user}.home.homeDirectory}";
      devices = {
        mbp13 = {
          id = "A5U7AZU-QIFZ5LZ-WDHZHSD-OQBSOTM-D3XOP2D-IU7TY2L-MEZTR3J-H3DJCQP";
        };
        m3800 = {
          id = "TO7DEHZ-L3KL5SE-OY7WWXF-QDT7DON-7IWM3NV-X3MES2U-TWYTJ6J-YKGT7QJ";
        };
      };
      otherDevices = lib.filterAttrs (n: _: n != config.networking.hostName) devices;
    in
    mkIf cfg.enable {
      services = {
        syncthing = {
          enable = true;
          guiAddress = "0.0.0.0:8384";
          user = cfg.user;
          group = "wheel";
          dataDir = "${homeDirectory}";
          configDir = "${config.home-manager.users.${cfg.user}.xdg.configHome}/syncthing";
          openDefaultPorts = true;
          overrideDevices = true; # overrides any devices added or deleted through the WebUI
          overrideFolders = true; # overrides any folders added or deleted through the WebUI
          settings = {
            devices = otherDevices;
            folders = {
              "Documents" = {
                path = "${homeDirectory}/Documents"; # Which folder to add to Syncthing
                devices = lib.attrNames otherDevices;
                type = if cfg.bidirectional then "sendreceive" else "receiveonly";
              };
              "obsidian" = {
                path = "${homeDirectory}/obsidian";
                devices = lib.attrNames otherDevices;
                type = if cfg.bidirectional then "sendreceive" else "receiveonly";
              };
            };
          };
        };
      };
    };
}
