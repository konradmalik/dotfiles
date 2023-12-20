{ pkgs, lib, ... }: {
  fontProfiles = {
    enable = true;
    monospace = {
      family = "MonaspiceNe Nerd Font";
      package = pkgs.nerdfonts.override { fonts = [ "Monaspace" ]; };
      size = lib.mkDefault 11;
    };
    regular = {
      family = "Fira Sans";
      package = pkgs.fira;
      size = lib.mkDefault 11;
    };
  };
}
