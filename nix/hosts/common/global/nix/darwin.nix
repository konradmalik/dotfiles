{ config, lib, ... }:
{
  imports = [ ./shared.nix ];
  nix = {
    configureBuildUsers = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      interval = {
        Hour = 2;
        Minute = 0;
      };
    };
  };
  services.nix-daemon.enable = true;
}
