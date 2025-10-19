{ config, lib, ... }:
with lib;
let
  cfg = config.konrad.services.syncthing;
in
{
  options.konrad.services.syncthing = {
    enable = mkEnableOption "Enables syncthing and its configuration through nixos (uses home-manager as well)";

    user = mkOption {
      type = types.str;
      description = "user name";
    };

    bidirectional = mkOption {
      type = types.bool;
      description = "Whether to use receiveonly or sendreceive mode.";
    };
  };
  config =
    let
      devices = {
        framework.id = "S55JBIK-J5N2KHL-YFBB7A2-AQANZCQ-SEYILMM-OP6SZBB-6Y75A44-3PMY5AR";
        m3800.id = "YK6ZS47-ICAUGTU-4UVXSWS-NAG4ICS-3TV6LVF-XZVLATA-KAIS4DV-NI2KEQZ";
        mbp13.id = "A5U7AZU-QIFZ5LZ-WDHZHSD-OQBSOTM-D3XOP2D-IU7TY2L-MEZTR3J-H3DJCQP";
        rpi4-1.id = "HHMMUAO-2ADZE5M-DYXO5P5-AA7GE22-XCEWHMK-ZH2WAL3-ZWQFZ3N-ELJ5BA7";
        rpi4-2.id = "I5455AU-F2ZA6OT-O3KAIZS-7UGVDKA-OYF2T7P-RA556GI-FJKGNGN-ARXD5AP";
      };
      otherDevices = lib.filterAttrs (n: _: n != config.networking.hostName) devices;

      homeDirectory = config.home-manager.users.${cfg.user}.home.homeDirectory;
    in
    mkIf cfg.enable {
      services = {
        syncthing = {
          enable = true;
          guiAddress = "127.0.0.1:8384";
          user = cfg.user;
          group = "wheel";
          dataDir = homeDirectory;
          configDir = "${config.home-manager.users.${cfg.user}.xdg.configHome}/syncthing";
          openDefaultPorts = true;
          overrideDevices = true;
          overrideFolders = true;
          settings = {
            devices = otherDevices;
            folders = {
              "Documents" = {
                path = "${homeDirectory}/Documents";
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
