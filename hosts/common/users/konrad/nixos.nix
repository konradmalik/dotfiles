{
  config,
  pkgs,
  lib,
  ...
}:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  home-manager.users.konrad = import ./../../../../home/konrad/${config.networking.hostName}.nix;

  users = {
    # NOTE: disable this when installing on a new machine
    # to set `passwd konrad`
    mutableUsers = false;
    users.konrad = {
      openssh.authorizedKeys.keys = config.home-manager.users.konrad.sshKeys.personal.keys;
      hashedPasswordFile = config.sops.secrets.konrad-password.path;
      shell = pkgs.zsh;
      isNormalUser = true;
      description = "Konrad";
      extraGroups = [
        "wheel"
        "video"
        "audio"
      ]
      ++ ifTheyExist [
        "docker"
      ];
    };
  };

  # required if users use zsh
  programs.zsh.enable = true;

  sops.secrets.konrad-password = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };

  # Syncthing ports
  networking.firewall = {
    allowedTCPPorts = lib.optionals config.home-manager.users.konrad.konrad.services.syncthing.enable [
      22000 # TCP based sync protocol traffic
    ];
    allowedUDPPorts = lib.optionals config.home-manager.users.konrad.konrad.services.syncthing.enable [
      22000 # QUIC based sync protocol traffic
      21027 # for discovery broadcasts on IPv4 and multicasts on IPv6
    ];
  };
}
