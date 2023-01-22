{ config, pkgs, outputs, ... }:
{
  programs.k9s = {
    enable = true;
    skin =
      let c = config.colorscheme.colors;
      in builtins.fromJSON
        ''
          {
            "k9s": {
              "body": {
                "fgColor": "#${c.base05}",
                "bgColor": "default",
                "logoColor": "#${c.base0C}"
              },
              "prompt": {
                "fgColor": "#${c.base05}",
                "bgColor": "#${c.base00}",
                "suggestColor": "#${c.base0A}"
              },
              "info": {
                "fgColor": "#${c.base0B}",
                "sectionColor": "#${c.base05}"
              },
              "dialog": {
                "fgColor": "#${c.base05}",
                "bgColor": "default",
                "buttonFgColor": "#${c.base05}",
                "buttonBgColor": "#${c.base0C}",
                "buttonFocusFgColor": "#${c.base0E}",
                "buttonFocusBgColor": "#${c.base0B}",
                "labelFgColor": "#${c.base0A}",
                "fieldFgColor": "#${c.base05}"
              },
              "frame": {
                "border": {
                  "fgColor": "#${c.base02}",
                  "focusColor": "#${c.base01}"
                },
                "menu": {
                  "fgColor": "#${c.base05}",
                  "keyColor": "#${c.base0B}",
                  "numKeyColor": "#${c.base0B}"
                },
                "crumbs": {
                  "fgColor": "#${c.base05}",
                  "bgColor": "#${c.base01}",
                  "activeColor": "#${c.base01}"
                },
                "status": {
                  "newColor": "#${c.base08}",
                  "modifyColor": "#${c.base0C}",
                  "addColor": "#${c.base09}",
                  "errorColor": "#${c.base0D}",
                  "highlightcolor": "#${c.base0A}",
                  "killColor": "#${c.base03}",
                  "completedColor": "#${c.base03}"
                },
                "title": {
                  "fgColor": "#${c.base05}",
                  "bgColor": "#${c.base01}",
                  "highlightColor": "#${c.base0A}",
                  "counterColor": "#${c.base0C}",
                  "filterColor": "#${c.base0B}"
                }
              },
              "views": {
                "charts": {
                  "bgColor": "default",
                  "defaultDialColors": [
                    "#${c.base0C}",
                    "#${c.base0D}"
                  ],
                  "defaultChartColors": [
                    "#${c.base0C}",
                    "#${c.base0D}"
                  ]
                },
                "table": {
                  "fgColor": "#${c.base05}",
                  "bgColor": "default",
                  "header": {
                    "fgColor": "#${c.base05}",
                    "bgColor": "default",
                    "sorterColor": "#${c.base08}"
                  }
                },
                "xray": {
                  "fgColor": "#${c.base05}",
                  "bgColor": "default",
                  "cursorColor": "#${c.base01}",
                  "graphicColor": "#${c.base0C}",
                  "showIcons": false
                },
                "yaml": {
                  "keyColor": "#${c.base0B}",
                  "colonColor": "#${c.base0C}",
                  "valueColor": "#${c.base05}"
                },
                "logs": {
                  "fgColor": "#${c.base05}",
                  "bgColor": "default",
                  "indicator": {
                    "fgColor": "#${c.base05}",
                    "bgColor": "#${c.base0C}"
                  }
                },
                "help": {
                  "fgColor": "#${c.base05}",
                  "bgColor": "#${c.base00}",
                  "indicator": {
                    "fgColor": "#${c.base0D}"
                  }
                }
              }
            }
          }
        '';
  };
}
