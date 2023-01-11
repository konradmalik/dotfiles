{ config, pkgs, username, ... }:
{
  imports = [
    ./../presets/darwin.nix
  ];

  nixpkgs.system = "x86_64-darwin";

  networking.hostName = "mbp13";

  nix = {
    settings = {
      min-free = 107374182400; # 100GB
      max-free = 214748364800; # 200GB
      cores = 4;
      max-jobs = 8;
    };
  };
}
