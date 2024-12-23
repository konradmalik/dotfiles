{ pkgs, lib, ... }:
{
  fontProfiles = {
    enable = true;
    monospace = {
      family = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
      size = lib.mkDefault 13;
    };
    regular = {
      family = "Fira Sans";
      package = pkgs.fira;
      size = lib.mkDefault 11;
    };
  };
}
