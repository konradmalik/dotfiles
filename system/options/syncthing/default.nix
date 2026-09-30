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
      homeDirectory = config.users.users.${cfg.user}.home;
    in
    lib.mkIf cfg.enable {
      services.syncthing = {
        enable = true;
        guiAddress = "127.0.0.1:8384";
        user = cfg.user;
        group = config.users.users.${cfg.user}.group;
        dataDir = homeDirectory;
        openDefaultPorts = true;
        settings = import ./settings.nix lib {
          inherit (config.networking) hostName;
          type = if cfg.bidirectional then "sendreceive" else "receiveonly";
          folders = lib.genAttrs [ "Documents" "obsidian" ] (name: "${homeDirectory}/${name}");
        };
      };
    };
}
