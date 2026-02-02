{
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ../modules/base
    ../modules/desktop/common/alacritty.nix
    ../modules/desktop/common/ghostty.nix
    ../modules/desktop/common/mpv.nix
  ];

  home = {
    file.".face".source = ../../../../files/avatar.png;

    packages = with pkgs; [
      # make linux people at home
      coreutils
      # make sure we use gnu versions of common commands
      findutils
      gawk
      gnugrep
      gnused
    ];

    sessionVariables.XDG_RUNTIME_DIR = "$TMPDIR";
  };

  programs.zsh = {
    shellAliases = {
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    };
    initContent = lib.optionalString osConfig.homebrew.enable ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };
}
