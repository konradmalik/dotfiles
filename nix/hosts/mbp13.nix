{ config, pkgs, username, ... }:
{
  imports = [
    ./presets/darwin.nix
  ];

  nix = {
    settings = {
      min-free = 107374182400; # 100GB
      max-free = 214748364800; # 200GB
    };
  };

  networking.hostName = "mbp13";

  users.users.${username} = {
    name = "${username}";
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
}
