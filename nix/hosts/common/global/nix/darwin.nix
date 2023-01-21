{ config, lib, ... }:
{
  imports = [ ./shared.nix ];
  nix = {
    configureBuildUsers = true;
    gc.interval = {
      Hour = 2;
      Minute = 0;
    };
  };
  services.nix-daemon.enable = true;
}
