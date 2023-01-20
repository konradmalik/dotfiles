{ config, pkgs, outputs, ... }:
{
  programs.k9s = {
    enable = true;
    skin =
      let c = config.colorscheme.colors;
      in outputs.lib.${pkgs.system}.default.yaml-utils.fromYAML
        ''
          foreground: &foreground "#${c.base05}"
          background: &background "#${c.base00}"
          comment: &comment "#${c.base03}"
          current_line: &current_line "#${c.base01}"
          selection: &selection "#${c.base02}"
          cyan: &cyan "#${c.base08}"
          green: &green "#${c.base09}"
          orange: &orange "#${c.base0A}"
          blue: &blue "#${c.base0B}"
          magenta: &magenta "#${c.base0C}"
          red: &red "#${c.base0D}"
          yellow: &yellow "#${c.base0E}"

          k9s:
            # General K9s styles
            body:
              fgColor: *foreground
              bgColor: default
              logoColor: *magenta
            # Command prompt styles
            prompt:
              fgColor: *foreground
              bgColor: *background
              suggestColor: *orange
            # ClusterInfoView styles.
            info:
              fgColor: *blue
              sectionColor: *foreground
            # Dialog styles.
            dialog:
              fgColor: *foreground
              bgColor: default
              buttonFgColor: *foreground
              buttonBgColor: *magenta
              buttonFocusFgColor: *yellow
              buttonFocusBgColor: *blue
              labelFgColor: *orange
              fieldFgColor: *foreground
            frame:
              # Borders styles.
              border:
                fgColor: *selection
                focusColor: *current_line
              menu:
                fgColor: *foreground
                keyColor: *blue
                # Used for favorite namespaces
                numKeyColor: *blue
              # CrumbView attributes for history navigation.
              crumbs:
                fgColor: *foreground
                bgColor: *current_line
                activeColor: *current_line
              # Resource status and update styles
              status:
                newColor: *cyan
                modifyColor: *magenta
                addColor: *green
                errorColor: *red
                highlightcolor: *orange
                killColor: *comment
                completedColor: *comment
              # Border title styles.
              title:
                fgColor: *foreground
                bgColor: *current_line
                highlightColor: *orange
                counterColor: *magenta
                filterColor: *blue
            views:
              # Charts skins...
              charts:
                bgColor: default
                defaultDialColors:
                  - *magenta
                  - *red
                defaultChartColors:
                  - *magenta
                  - *red
              # TableView attributes.
              table:
                fgColor: *foreground
                bgColor: default
                # Header row styles.
                header:
                  fgColor: *foreground
                  bgColor: default
                  sorterColor: *cyan
              # Xray view attributes.
              xray:
                fgColor: *foreground
                bgColor: default
                cursorColor: *current_line
                graphicColor: *magenta
                showIcons: false
              # YAML info styles.
              yaml:
                keyColor: *blue
                colonColor: *magenta
                valueColor: *foreground
              # Logs styles.
              logs:
                fgColor: *foreground
                bgColor: default
                indicator:
                  fgColor: *foreground
                  bgColor: *magenta
              help:
                fgColor: *foreground
                bgColor: *background
                indicator:
                  fgColor: *red
        '';
  };
}
