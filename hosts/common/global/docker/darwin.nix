{ pkgs, ... }:
{
  darwin-docker = {
    enable = true;
    ephemeral = true;
    package = pkgs.stable.darwin.linux-builder;
  };
}
