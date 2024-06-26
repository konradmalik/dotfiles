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
      ephemeral = true;
      package = pkgs.darwin.linux-builder;
    };
  };
  services.nix-daemon.enable = true;
}
