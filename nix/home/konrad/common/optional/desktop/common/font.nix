{ pkgs, lib, ... }: {
  fontProfiles = {
    enable = true;
    monospace = {
      family = "Hack Nerd Font";
      package = pkgs.nerdfonts.override { fonts = [ "Hack" ]; };
      size = lib.mkDefault 13;
    };
    regular = {
      family = "Fira Sans";
      package = pkgs.fira;
      size = lib.mkDefault 11;
    };
  };
}
