{ config, pkgs, lib, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  home-manager.users.konrad = import ./../../../../home/konrad/${config.networking.hostName}.nix;

  users = {
    mutableUsers = false;
    users.konrad = {
      openssh.authorizedKeys.keys = config.home-manager.users.konrad.sshKeys.personal.keys;
      passwordFile = config.sops.secrets.konrad-password.path;
      shell = pkgs.zsh;
      isNormalUser = true;
      description = "Konrad";
      # network is my own custom group for imperative wpa_supplicant config
      extraGroups = [ "wheel" "video" "audio" ] ++ ifTheyExist [ "network" "docker" "networkmanager" ];
    };
  };

  sops.secrets.konrad-password = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };
}
