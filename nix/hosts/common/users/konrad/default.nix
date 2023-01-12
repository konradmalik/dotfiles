{ config, pkgs, lib, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  home-manager.users.konrad = import ./../../../../home/konrad/${config.networking.hostName}.nix;

  users = {
    mutableUsers = false;
    users.konrad = {
      # If you are using NixOps then don't use this option since it will replace the key required for deployment via ssh.
      openssh.authorizedKeys.keys =
        let
          authorizedKeysFile = builtins.readFile "${pkgs.dotfiles}/ssh/authorized_keys";
          authorizedKeysFileLines = lib.splitString "\n" authorizedKeysFile;
          onlyKeys = lib.filter (line: line != "" && !(lib.hasPrefix "#" line)) authorizedKeysFileLines;
        in
        onlyKeys;

      passwordFile = config.sops.secrets.konrad-password.path;
      shell = pkgs.zsh;
      isNormalUser = true;
      description = "Konrad";
      extraGroups = [ "wheel" "video" "audio" ] ++ ifTheyExist [ "docker" "networkmanager" ];
    };
  };

  sops.secrets.konrad-password = {
    sopsFile = ./secrets.yaml;
    neededForUsers = true;
  };

}
