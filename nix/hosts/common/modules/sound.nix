{ config, lib, pkgs, ... }:
with lib;
let cfg = config.konrad.audio;
in
{
  options.konrad.audio = {
    enable = mkEnableOption "Enables audio thorugh configured pipewire";
  };

  config = mkIf cfg.enable {
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
  };
}
