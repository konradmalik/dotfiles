{ config, lib, pkgs, username, ... }:
with lib;
let cfg = config.konrad.programs.desktop;
in
{
  options.konrad.programs.desktop = {
    enable = mkEnableOption "Enables the GUI";

    enableApps = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to also enable desktop apps";
    };
  };

  config =
    let
      # bash script to let dbus know about important env variables and
      # propagate them to relevent services run at the end of sway config
      # see
      # https://github.com/emersion/xdg-desktop-portal-wlr/wiki/"It-doesn't-work"-Troubleshooting-Checklist
      # note: this is pretty much the same as  /etc/sway/config.d/nixos.conf but also restarts
      # some user services to make sure they have the correct environment variables
      dbus-sway-environment = pkgs.writeTextFile {
        name = "dbus-sway-environment";
        destination = "/bin/dbus-sway-environment";
        executable = true;

        text = ''
          dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
          systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
          systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
        '';
      };
    in
    mkIf cfg.enable {

      # xdg-desktop-portal works by exposing a series of D-Bus interfaces
      # known as portals under a well-known name
      # (org.freedesktop.portal.Desktop) and object path
      # (/org/freedesktop/portal/desktop).
      # The portal interfaces include APIs for file access, opening URIs,
      # printing and others.
      services.dbus.enable = true;
      xdg.portal = {
        enable = true;
        wlr.enable = true;
        # gtk portal needed to make gtk apps happy
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
          dbus-sway-environment
          pulseaudioFull # for pactl volume control and modules like raop (used by pipewire as well)
          xdg-utils # for openning default programms when clicking links
          bluez-tools # for bluetoothctl and other stuff
          swaylock
          swayidle
          networkmanagerapplet # nm-connection-edit
          pavucontrol # audio gui
          libnotify # notify-send
          wl-clipboard
          wl-clipboard-x11
          gnome.eog
        ];
      };

      # enable proper wayland support for some apps globally
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      programs.light.enable = true;

      users.users.${username} = {
        # Brightness and volume
        extraGroups = [ "video" ];
        # desktop apps
        packages = with pkgs; optionals cfg.enableApps [
          alacritty
          bitwarden
          unstable.discord
          firefox
          obsidian
          unstable.signal-desktop
          unstable.slack
          unstable.spotify
          unstable.teams
          unstable.tdesktop
          vlc
          zathura
        ];
      };
    };
}