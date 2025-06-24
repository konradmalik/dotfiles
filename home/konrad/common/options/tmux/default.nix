{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.konrad.programs.tmux;
  tmuxTextProcessor = pkgs.callPackage ./text_processor.nix { };
  tmux-sessionizer = pkgs.callPackage ./tmux-sessionizer { };
  tmux-switcher = pkgs.callPackage ./tmux-switcher { };
  tmux-windowizer = pkgs.callPackage ./tmux-windowizer { };
  baseConfig = pkgs.callPackage ./config.nix {
    inherit tmuxTextProcessor tmux-switcher tmux-sessionizer;
  };
  themeConfig = import ./theme.nix { inherit (cfg) colorscheme; };
in
{
  options.konrad.programs.tmux = {
    enable = mkEnableOption "Enables personalized tmux through home-manager";

    colorscheme = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = config.colorscheme;
      description = "Colorscheme attrset compatible with nix-colors format.";
      example = "config.colorscheme";
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      aggressiveResize = true;
      # there's a bug, and my settings are sensible for me
      sensibleOnTop = false;
      # tmux-256color is the proper one to enable italics, undercurls etc.
      # just ensure you have that terminfo
      # screen-256color works properly everywhere but does not have many features
      terminal = "tmux-256color";
      keyMode = "vi";
      escapeTime = 0;
      baseIndex = 1;
      historyLimit = 50000;
      extraConfig = lib.concatStringsSep "\n" [
        baseConfig
        themeConfig
      ];
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.extrakto;
          extraConfig = "set -g @extrakto_grab_area 'window recent'";
        }
      ];
    };

    programs.git.ignores = [ ".tmux.sh" ];

    programs.fzf.tmux.enableShellIntegration = true;

    home.packages = [
      tmux-sessionizer
      tmux-windowizer
      tmux-switcher
    ];
  };
}
