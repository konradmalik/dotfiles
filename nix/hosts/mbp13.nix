{ config, pkgs, username, ... }:
{
  imports = [
    ./presets/darwin.nix
  ];

  nix = {
    settings = {
      min-free = 107374182400; # 100GB
      max-free = 214748364800; # 200GB
      cores = 2;
      max-jobs = 8;
    };
  };

  networking.hostName = "mbp13";
}
