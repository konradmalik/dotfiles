{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    bashmount
    grim # screenshots
    slurp # screenshots
    mako # notification system developed by swaywm maintainer
    waybar # status bar
    wofi # wayland clone of rofi
  ];

  # sway
  xdg.configFile = {
    # sway
    "sway/config".source = "${pkgs.dotfiles}/sway/config";
    "swaylock/config".source = "${pkgs.dotfiles}/swaylock/config";
    # mako
    "mako/config".source = "${pkgs.dotfiles}/mako/config";
    # waybar
    "waybar/config".source = "${pkgs.dotfiles}/waybar/config";
    "waybar/style.css".source = "${pkgs.dotfiles}/waybar/style.css";
    "waybar/catppuccin-macchiato.css".source = "${pkgs.dotfiles}/waybar/catppuccin-macchiato.css";
    # wofi
    "wofi/config".source = "${pkgs.dotfiles}/wofi/config";
    "wofi/style.css".source = "${pkgs.dotfiles}/wofi/style.css";
  };

  # because we manage sway outside of home-manager
  # systemd targets for below services are never reached
  # so we start them manually in sway/config
  services = {
    # night light
    wlsunset = {
      enable = true;
      systemdTarget = "graphical-session.target";
      # warsaw
      latitude = "52.2";
      longitude = "21.0";
    };

    # dynamic output profiles
    kanshi = {
      enable = true;
      # even though this is not used, service won't start manually if this target does not exist
      # ex. sway-session.target does not exist on my system
      systemdTarget = "graphical-session.target";
      profiles = {
        laptop = {
          outputs = [
            {
              criteria = "eDP-1";
              mode = "3840x2160@59.997Hz";
              position = "0,0";
              scale = 2.0;
              status = "enable";
              transform = "normal";
            }
          ];
        };
        # second profile for clamshell desktop
        # clamshell = {};
      };
    };
  };


  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk =
    let
      gtkExtraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
    in
    {
      enable = true;
      font = {
        name = "Hack Nerd Font";
        package = pkgs.nerdfonts.override { fonts = [ "Hack" ]; };
        size = 11;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        name = "Catppuccin-Teal-Dark";
        package = pkgs.catppuccin-gtk;
      };
      gtk3.extraConfig = gtkExtraConfig;
      gtk4.extraConfig = gtkExtraConfig;
    };
}
