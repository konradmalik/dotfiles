{ pkgs, ... }:
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
    linux-builder = {
      enable = true;
      # not sure why but it tries to build it when nixos-unstable is used
      package = pkgs.stable.darwin.linux-builder;
    };
  };
  services.nix-daemon.enable = true;
}
