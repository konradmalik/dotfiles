{ config, ... }:
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
      keys = config.users.users.konrad.openssh.authorizedKeys.keys;
      protocol = "ssh";
      write = true;
    };

    settings.trusted-users = [ "nix-ssh" ];
  };
}
