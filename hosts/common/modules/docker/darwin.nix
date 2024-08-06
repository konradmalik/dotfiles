{ inputs, ... }:
{
  imports = [ inputs.darwin-docker.darwinModules.docker ];

  virtualisation.docker = {
    enable = false;
    config = import ./linux.nix;
  };
}
