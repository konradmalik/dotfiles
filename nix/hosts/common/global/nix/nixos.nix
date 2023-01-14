{ config, lib, ... }:
let
  ifTheyExist = users: builtins.filter (user: builtins.hasAttr user config.users.users) users;
  theirAuthorizedKeys = users: builtins.map (user: config.users.users.${user}.openssh.authorizedKeys.keys) users;
in
{
  imports = [ ./shared.nix ];
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
      persistent = true;
    };

    optimise = {
      automatic = true;
      dates = [ "daily" ];
    };

    sshServe = {
      enable = true;
      keys = lib.flatten (theirAuthorizedKeys (ifTheyExist [ "konrad" ]));
      write = true;
    };

    settings.trusted-users = [ "nix-ssh" ];

    # Map registries to channels
    # Very useful when using legacy commands
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };
}
