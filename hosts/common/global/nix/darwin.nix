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
      enable = false;
      # TODO
      # ephemeral = true;
      package = pkgs.stable.darwin.linux-builder;
    };
  };
  services.nix-daemon.enable = true;
}
