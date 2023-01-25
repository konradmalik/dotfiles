{ config, pkgs, lib, ... }:
let
  konradKeys = pkgs.callPackage ./../../../../home/konrad/common/global/ssh-keys.nix { };
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  home-manager.users.konrad = import ./../../../../home/konrad/${config.networking.hostName}.nix;

  users = {
    mutableUsers = false;
    users.konrad = {
      openssh.authorizedKeys.keys = konradKeys.sshKeys.personal;
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
