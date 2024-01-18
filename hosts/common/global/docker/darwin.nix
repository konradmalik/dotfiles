{ pkgs, ... }:
{
  darwin-docker = {
    enable = false;
    ephemeral = true;
    package = pkgs.stable.darwin.linux-builder;
  };
}
