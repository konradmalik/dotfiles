{ pkgs, ... }:
{
  imports = [
    ./alacritty.nix
    ./audio.nix
    ./ghostty.nix
    ./hidden.nix
    ./firefox.nix
    ./imv.nix
    ./mpv.nix
    ./ssh-agent.nix
    ./zathura.nix

    ./hyprland
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./hyprsunset.nix
    ./quickshell
  ];

  xdg.mimeApps.enable = true;
  # silently override mimeapps
  xdg.configFile."mimeapps.list".force = true;

  home = {
    packages = with pkgs; [
      bitwarden-desktop
      calibre
      obsidian
      signal-desktop
      slack
      spotify
      # for xdg-open in 'gx' in vim for example
      xdg-utils

      hyprshot
      swappy
    ];

    sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";
  };

  gtk.enable = true;
  # https://github.com/nix-community/stylix/issues/1560
  stylix.targets.gtk.extraCss =
    # css
    ''
      .dialog-action-area > .text-button {
        color: @dialog_fg_color;
      }
    '';
  qt.enable = true;
}
