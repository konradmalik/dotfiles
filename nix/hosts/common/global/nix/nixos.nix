{ config, lib, ... }:
let
  ifTheyExist = users: builtins.filter (user: builtins.hasAttr user config.users.users) users;
  theirAuthorizedKeys = users: builtins.map (user: config.users.users.${user}.openssh.authorizedKeys.keys) users;
in
{
  imports = [ ./shared.nix ];
  nix = {
    gc = {
      dates = "daily";
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
  };
}
