{ config, ... }:

{
  imports = [
    ./common/presets/darwin.nix
  ];

  home.homeDirectory = "/Users/${config.home.username}";

  fontProfiles = {
    enable = true;
    monospace.size = 16.0;
  };
  konrad.programs.gpg-agent.enable = true;
  konrad.programs.ssh-egress.enable = true;
  konrad.programs.bitwarden.enable = true;
  konrad.programs.alacritty = {
    enable = true;
    # installed via homebrew
    package = null;
  };
}
