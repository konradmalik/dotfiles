{ config, ... }:

{
  imports = [
    ./common/presets/darwin.nix
  ];

  home.homeDirectory = "/Users/${config.home.username}";

  konrad.fontProfiles.enable = true;
  konrad.programs.ssh-egress.enable = true;
  konrad.programs.alacritty = {
    enable = true;
    fontSize = 16.0;
    # installed via homebrew
    package = null;
  };
}
