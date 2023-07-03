{ pkgs, lib, ... }: {
  fontProfiles = {
    enable = true;
    monospace = {
      family = "IosevkaTerm Nerd Font";
      package = pkgs.nerdfonts.override { fonts = [ "IosevkaTerm" ]; };
      size = lib.mkDefault 13;
    };
    regular = {
      family = "Fira Sans";
      package = pkgs.fira;
      size = lib.mkDefault 11;
    };
  };
}
