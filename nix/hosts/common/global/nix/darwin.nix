{ config, lib, ... }:
{
  imports = [ ./shared.nix ];
  nix = {
    configureBuildUsers = true;
    # must be >= max-jobs
    nrBuildUsers = 16;

    gc = {
      automatic = true;
      interval = {
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 14d";
    };

    # Map registries to channels
    # Very useful when using legacy commands
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };
  services.nix-daemon.enable = true;
}
