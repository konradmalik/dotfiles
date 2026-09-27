{
  config,
  pkgs,
  ...
}:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
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
        "networkmanager"
        # access to the tpm, only exists if security.tpm2 is enabled
        "tss"
      ];
    };
  };

  sops.defaultSopsFile = ../../secrets/system.yaml;

  konrad.services.syncthing.user = "konrad";
}
