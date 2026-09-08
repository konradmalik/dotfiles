{ config, lib, ... }:
let
  cfg = config.konrad.services.syncthing;
in
{
  options.konrad.services.syncthing = {
    enable = lib.mkEnableOption "Enables syncthing and its configuration through nixos";

    user = lib.mkOption {
      type = lib.types.str;
      description = "user name";
    };

    bidirectional = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use receiveonly or sendreceive mode.";
    };
  };
  config =
    let
      devices = {
        framework.id = "S55JBIK-J5N2KHL-YFBB7A2-AQANZCQ-SEYILMM-OP6SZBB-6Y75A44-3PMY5AR";
        m4.id = "PHJIM6R-6CEM2HB-HNCTY4F-SFGWH5J-BBTNDB6-6AB3S7P-IXPCVDH-7LTZNAQ";
        rpi4-1.id = "HHMMUAO-2ADZE5M-DYXO5P5-AA7GE22-XCEWHMK-ZH2WAL3-ZWQFZ3N-ELJ5BA7";
        rpi4-2.id = "I5455AU-F2ZA6OT-O3KAIZS-7UGVDKA-OYF2T7P-RA556GI-FJKGNGN-ARXD5AP";
        x1c6.id = "44QKQXH-FWGCUJB-O4S36QZ-2LJ23DS-GXP5CAC-EIS75BN-EXRSY54-H5TAJAE";
      };
      hostName = config.networking.hostName;
      otherDevices = lib.filterAttrs (n: _: n != hostName) devices;

      homeDirectory = config.users.users.${cfg.user}.home;

      mkFolder = name: {
        path = "${homeDirectory}/${name}";
        devices = lib.attrNames otherDevices;
        type = if cfg.bidirectional then "sendreceive" else "receiveonly";
      };
    in
    lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = devices ? ${hostName};
          message = "konrad.services.syncthing: ${hostName} is not in the devices list";
        }
      ];

      services.syncthing = {
        enable = true;
        guiAddress = "127.0.0.1:8384";
        user = cfg.user;
        group = config.users.users.${cfg.user}.group;
        dataDir = homeDirectory;
        openDefaultPorts = true;
        settings = {
          devices = otherDevices;
          folders = lib.genAttrs [ "Documents" "obsidian" ] mkFolder;
        };
      };
    };
}
