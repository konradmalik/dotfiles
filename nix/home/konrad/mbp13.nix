{ config, ... }:

{
  imports = [
    ./common/presets/darwin.nix
  ];

  home.homeDirectory = "/Users/${config.home.username}";

  konrad.fontProfiles = {
    enable = true;
    monospace.size = 16.0;
  };
  konrad.programs.ssh-egress.enable = true;
  konrad.programs.alacritty = {
    enable = true;
    # installed via homebrew
    package = null;
  };
}
