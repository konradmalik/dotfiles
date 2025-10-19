{
  config,
  pkgs,
  ...
}:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  home-manager.users.konrad = import ./../../../../home/konrad/${config.networking.hostName}.nix;

  users = {
    users.konrad = {
      openssh.authorizedKeys.keys = config.home-manager.users.konrad.sshKeys.personal.keys;
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

  sops.defaultSopsFile = ./secrets.yaml;

  # required if users use zsh
  programs.zsh.enable = true;

  konrad.services.syncthing.user = "konrad";
}
