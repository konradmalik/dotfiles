{
  lib,
  config,
  ...
}:
let
  palette = config.colorscheme.palette;
  fontSize = config.fontProfiles.monospace.size;
  fontFamily = config.fontProfiles.monospace.family;
in
{
  programs.ghostty = {
    enable = lib.mkDefault true;
    settings = {
      font-family = fontFamily;
      font-size = fontSize;

      confirm-close-surface = false;
      gtk-single-instance = false;
      gtk-titlebar = false;
      mouse-hide-while-typing = true;
      shell-integration-features = true;

      theme = "custom";
    };
    themes = {
      custom = {
        background = "#${palette.base00}";
        foreground = "#${palette.base05}";

        selection-background = "#${palette.base02}";
        selection-foreground = "#${palette.base00}";
        palette = [
          "0=#${palette.base00}"
          "1=#${palette.base08}"
          "2=#${palette.base0B}"
          "3=#${palette.base0A}"
          "4=#${palette.base0D}"
          "5=#${palette.base0E}"
          "6=#${palette.base0C}"
          "7=#${palette.base05}"
          "8=#${palette.base03}"
          "9=#${palette.base08}"
          "10=#${palette.base0B}"
          "11=#${palette.base0A}"
          "12=#${palette.base0D}"
          "13=#${palette.base0E}"
          "14=#${palette.base0C}"
          "15=#${palette.base07}"
          "16=#${palette.base09}"
          "17=#${palette.base0F}"
          "18=#${palette.base01}"
          "19=#${palette.base02}"
          "20=#${palette.base04}"
          "21=#${palette.base06}"
        ];
      };
    };
  };
}
