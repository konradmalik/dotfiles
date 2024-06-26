{ pkgs, inputs, ... }:
{
  imports = [ inputs.darwin-docker.darwinModules.docker ];

  virtualisation.docker = {
    enable = false;
    ephemeral = true;
    package = pkgs.darwin.linux-builder;
    config = import ./linux.nix;
  };
}
