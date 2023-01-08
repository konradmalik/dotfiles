{ pkgs, lib, username, ... }:
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
{
  # Enable sound with pipewire.
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    config.pipewire = {
      "context.modules" = [
        # NOTE: Arrays are replaced rather than merged with defaults, so in order to keep any default items in the configuration, they have to be listed.
        # https://github.com/PipeWire/pipewire/blob/master/src/daemon/pipewire.conf.in

        #{ name = <module-name>
        #    [ args  = { <key> = <value> ... } ]
        #    [ flags = [ [ ifexists ] [ nofail ] ]
        #}
        #
        # Loads a module with the given parameters.
        # If ifexists is given, the module is ignored when it is not found.
        # If nofail is given, module initialization failures are ignored.
        #

        # Uses realtime scheduling to boost the audio thread priorities. This uses
        # RTKit if the user doesn't have permission to use regular realtime
        # scheduling.
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -11;
            # "rt.prio" = 88;
            # "rt.time.soft" = 200000;
            # "rt.time.hard" = 200000;
          };
          flags = [ "ifexists" "nofail" ];
        }

        # The native communication protocol.
        { name = "libpipewire-module-protocol-native"; }

        # The profile module. Allows application to access profiler
        # and performance data. It provides an interface that is used
        # by pw-top and pw-profiler.
        { name = "libpipewire-module-profiler"; }

        # Allows applications to create metadata objects. It creates
        # a factory for Metadata objects.
        { name = "libpipewire-module-metadata"; }

        # Creates a factory for making devices that run in the
        # context of the PipeWire server.
        { name = "libpipewire-module-spa-device-factory"; }

        # Creates a factory for making nodes that run in the
        # context of the PipeWire server.
        { name = "libpipewire-module-spa-node-factory"; }

        # Allows creating nodes that run in the context of the
        # client. Is used by all clients that want to provide
        # data to PipeWire.
        { name = "libpipewire-module-client-node"; }

        # Allows creating devices that run in the context of the
        # client. Is used by the session manager.
        { name = "libpipewire-module-client-device"; }

        # The portal module monitors the PID of the portal process
        # and tags connections with the same PID as portal
        # connections.
        {
          name = "libpipewire-module-portal";
          flags = [ "ifexists" "nofail" ];
        }

        # The access module can perform access checks and block
        # new clients.
        {
          name = "libpipewire-module-access";
          args = {
            # access.allowed to list an array of paths of allowed
            # apps.
            #access.allowed = [
            #    @session_manager_path@
            #]

            # An array of rejected paths.
            #access.rejected = [ ]

            # An array of paths with restricted access.
            #access.restricted = [ ]

            # Anything not in the above lists gets assigned the
            # access.force permission.
            #access.force = flatpak
          };
        }

        # Makes a factory for wrapping nodes in an adapter with a
        # converter and resampler.
        { name = "libpipewire-module-adapter"; }

        # Makes a factory for creating links between ports.
        { name = "libpipewire-module-link-factory"; }

        # Provides factories to make session manager objects.
        { name = "libpipewire-module-session-manager"; }

        # custom; require pulseaudioFull
        # discovers airplay devices automatically
        {
          name = "libpipewire-module-raop-discover";
          args = { };
        }
        # hardcoded sink (for some reason is not discovered by libpipewire-module-raop-discover)
        # maybe because its airplay1? or UDP?
        {
          name = "libpipewire-module-raop-sink";
          args = {
            "node.name" = "rpi4-1";
            "raop.hostname" = "192.168.0.35";
            "raop.port" = 5000;
            "raop.transport" = "udp";
          };
        }
      ];
    };
  };

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

  # Brightness and volume
  users.users.${username}.extraGroups = [ "video" ];
  programs.light.enable = true;

  services.blueman.enable = true;

  programs.ssh.startAgent = true;
}
