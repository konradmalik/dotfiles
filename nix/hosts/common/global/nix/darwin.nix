{ config, lib, ... }:
let
  arch = builtins.elemAt (lib.splitString "-" config.nixpkgs.system) 0;
in
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
    # https://nixos.org/manual/nixpkgs/stable/#sec-darwin-builder
    buildMachines = [
      {
        system = "${arch}-linux";
        # protocol = "ssh-ng";
        sshUser = "builder";
        sshKey = "/etc/nix/builder_ed25519";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo=";
        hostName = "localhost";
        maxJobs = 4;
      }
    ];
    distributedBuilds = true;
    settings.builders-use-substitutes = true;
  };
  services.nix-daemon.enable = true;
}
