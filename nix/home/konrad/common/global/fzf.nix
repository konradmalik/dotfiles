{ config, pkgs, lib, ... }:
{
  programs.fzf = rec {
    enable = true;
    defaultCommand = "${pkgs.fd}/bin/fd --type f";
    defaultOptions = [
      "--bind 'ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all'"
    ];
    fileWidgetCommand = defaultCommand;
    fileWidgetOptions = [
      "--preview '${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:200 {}'"
    ];
    colors =
      let c = config.colorscheme.colors;
      in with lib;{
        "bg+" = "#${toLower c.base01}";
        "bg" = "#${toLower c.base00}";
        "fg+" = "#${toLower c.base06}";
        "fg" = "#${toLower c.base04}";
        "hl+" = "#${toLower c.base0D}";
        "hl" = "#${toLower c.base0D}";
        "header" = "#${toLower c.base0D}";
        "info" = "#${toLower c.base0A}";
        "pointer" = "#${toLower c.base0C}";
        "marker" = "#${toLower c.base0C}";
        "spinner" = "#${toLower c.base0C}";
        "prompt" = "#${toLower c.base0A}";
      };
  };
}
