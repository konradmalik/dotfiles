{ config, pkgs, ... }:
{
  imports = [
    ./global/darwin.nix
  ];

  nix = {
    settings = {
      min-free = 107374182400; # 100GB
      max-free = 214748364800; # 200GB
    };
  };

  networking.hostName = "mbp13";

  users.users.konrad = {
    name = "konrad";
    home = "/Users/konrad";
    shell = pkgs.zsh;
  };
}
