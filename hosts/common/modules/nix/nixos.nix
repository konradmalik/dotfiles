{ config, lib, ... }:
let
  ifTheyExist = users: builtins.filter (user: builtins.hasAttr user config.users.users) users;
  theirAuthorizedKeys =
    users: builtins.map (user: config.users.users.${user}.openssh.authorizedKeys.keys) users;
in
{
  imports = [
    ./shared
    ./shared/not-hm.nix
  ];

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      dates = "daily";
      persistent = true;
    };

    sshServe = {
      enable = true;
      keys = lib.flatten (theirAuthorizedKeys (ifTheyExist [ "konrad" ]));
      write = true;
    };
  };
}
