{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:

let
  isLaptop = osConfig.services.upower.enable;

  colors = config.lib.stylix.colors.withHashtag;
  fonts = config.stylix.fonts;

  tailscale = "${osConfig.services.tailscale.package}/bin/tailscale";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  notify-send = "${pkgs.libnotify}/bin/notify-send";

  terminal = lib.getExe config.programs.alacritty.package;

  tailscaleCopyIp = pkgs.writeShellScript "quickshell-tailscale-copy-ip" ''
    set -euo pipefail
    ip="$(${tailscale} ip -4 2>/dev/null)" || ip=""
    # piping straight into wl-copy would clear the clipboard when down
    if [ -n "$ip" ]; then
      printf '%s' "$ip" | ${wl-copy}
    else
      ${notify-send} "Tailscale" "No address to copy"
    fi
  '';

  # up/down need the operator bit granted in hosts/common/modules/tailscale.nix
  tailscaleToggle = pkgs.writeShellScript "quickshell-tailscale-toggle" ''
    set -euo pipefail
    state="$(${tailscale} status --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.BackendState // ""')" || state=""

    notify() { ${notify-send} --urgency critical "Tailscale" "$1"; }

    case "$state" in
      Running)
        out="$(${tailscale} down 2>&1)" || notify "$out"
        ;;
      NeedsLogin)
        # up prints a login url and then waits for the browser, so this one has
        # to happen somewhere the url is actually readable
        ${terminal} -e /bin/sh -c "${tailscale} up"
        ;;
      *)
        # up blocks forever by default, and it refuses outright when prefs were
        # set with non-default flags, so bound it and surface whatever it said
        out="$(${tailscale} up --timeout 30s 2>&1)" || notify "$out"
        ;;
    esac
  '';

  # A camera exposes no "in use" flag to read, so the device nodes are watched
  # for open/close with inotify and fuser is asked who is holding them. Nothing
  # polls: the scan runs only when something actually opens or closes a camera.
  cameraWatch = pkgs.writeShellScript "quickshell-camera-watch" ''
    set -u

    set -- /dev/video*
    [ -e "$1" ] || { printf '\n'; exit 0; }

    # fuser prints the holding pids on stdout, and comm turns each one into the
    # name worth showing. One line of comma separated names, empty when idle.
    users() {
      out=""
      for pid in $(${pkgs.psmisc}/bin/fuser "$@" 2>/dev/null); do
        [ -r "/proc/$pid/comm" ] || continue
        read -r name < "/proc/$pid/comm" || continue
        case " $out " in
        *" $name "*) ;;
        *) out="''${out:+$out, }$name" ;;
        esac
      done
      printf '%s' "$out"
    }

    state=""
    emit() {
      new="$(users "$@")"
      if [ "$new" != "$state" ]; then
        state="$new"
        printf '%s\n' "$new"
      fi
    }

    # The scan is what decides; inotify only says when to run it, so a dropped
    # event costs nothing past the next open or close.
    ${pkgs.inotify-tools}/bin/inotifywait -q -m -e open -e close "$@" | {
      emit "$@"
      while read -r _; do emit "$@"; done
    }
  '';

  qmlString = value: ''"${value}"'';
  qmlList = values: "[${lib.concatMapStringsSep ", " qmlString values}]";
  qmlBool = value: if value then "true" else "false";

  # The one file the shell does not carry itself: everything the QML needs to
  # know about this machine, resolved out of the store rather than looked up on
  # PATH at runtime.
  env =
    pkgs.writeText "Env.qml"
      # qml
      ''
        pragma Singleton
        import Quickshell

        // Generated from Nix. Edit the module, not this file.
        Singleton {
            readonly property var colors: ({
                    base00: "${colors.base00}",
                    base01: "${colors.base01}",
                    base02: "${colors.base02}",
                    base03: "${colors.base03}",
                    base04: "${colors.base04}",
                    base05: "${colors.base05}",
                    base06: "${colors.base06}",
                    base07: "${colors.base07}",
                    base08: "${colors.base08}",
                    base09: "${colors.base09}",
                    base0A: "${colors.base0A}",
                    base0B: "${colors.base0B}",
                    base0C: "${colors.base0C}",
                    base0D: "${colors.base0D}",
                    base0E: "${colors.base0E}",
                    base0F: "${colors.base0F}"
                })

            readonly property string fontFamily: ${qmlString fonts.monospace.name}
            readonly property int fontSize: ${toString fonts.sizes.desktop}
            readonly property string popupFontFamily: ${qmlString fonts.sansSerif.name}
            readonly property int popupFontSize: ${toString fonts.sizes.popups}

            readonly property bool hasBattery: ${qmlBool isLaptop}
            readonly property bool hasBacklight: ${qmlBool isLaptop}
            readonly property bool hasTailscale: ${qmlBool osConfig.services.tailscale.enable}
            readonly property bool hasPowerProfiles: ${qmlBool osConfig.services.tlp.pd.enable}

            readonly property string distro: "${osConfig.system.nixos.distroName} ${osConfig.system.nixos.version} (${osConfig.system.nixos.codeName})"

            readonly property list<string> terminalArgv: ${
              qmlList [
                terminal
                "-e"
                "/bin/sh"
                "-c"
              ]
            }
            readonly property list<string> tailscaleToggle: ${qmlList [ "${tailscaleToggle}" ]}
            readonly property list<string> tailscaleCopyIp: ${qmlList [ "${tailscaleCopyIp}" ]}
            readonly property list<string> cameraWatch: ${qmlList [ "${cameraWatch}" ]}

            readonly property string systemMonitor: ${qmlString (lib.getExe config.programs.btop.package)}
            readonly property string mixer: ${qmlString (lib.getExe pkgs.wiremix)}
            readonly property string wifiTui: ${qmlString (lib.getExe pkgs.wifitui)}
            readonly property string bluetoothTui: ${qmlString (lib.getExe pkgs.bluetui)}

            readonly property string systemctl: "${pkgs.systemd}/bin/systemctl"
            readonly property string loginctl: "${pkgs.systemd}/bin/loginctl"
            readonly property string hyprctl: "${osConfig.programs.hyprland.package}/bin/hyprctl"
            readonly property string ip: "${pkgs.iproute2}/bin/ip"
            readonly property string brightnessctl: ${qmlString (lib.getExe pkgs.brightnessctl)}
            readonly property string tailscale: "${tailscale}"
        }
      '';

  # Quickshell reloads a config whenever its files change on disk, but the one
  # hyprland starts is this read-only store copy, so editing ./qs does nothing
  # until the next switch. To iterate without rebuilding, run the working tree
  # instead -- ./qs/Config/Env.qml is checked in as a stub for exactly this:
  #
  #   quickshell kill                       # stop the store copy
  #   quickshell -p ./qs                    # from this directory; ^C to stop
  #
  # Saving any file under ./qs now reloads the running shell in place. The stub
  # carries fallback colours, fonts and program paths rather than this host's,
  # so anything reading Env is approximate until the config is switched to.
  shell = pkgs.runCommandLocal "quickshell-shell" { } ''
    cp -r ${./qs} $out
    chmod -R u+w $out
    cp ${env} $out/Config/Env.qml

    # ./qs/Config/Env.qml is checked in for working-tree runs and for qmlls, so
    # it has to declare exactly what this module generates. Drift either way
    # shows up only as an undefined property at runtime, and only on one of the
    # two paths, so it is caught here instead.
    names() { grep -o 'property [a-zA-Z<>]* [a-zA-Z]*:' "$1" | awk '{ print $3 }' | sort; }
    if ! diff <(names ${./qs}/Config/Env.qml) <(names ${env}); then
      echo "Config/Env.qml stub declares different properties than the generated one (< stub, > generated)" >&2
      exit 1
    fi
  '';

in
{
  home.packages = [ pkgs.quickshell ];

  wayland.windowManager.hyprland.extraConfig =
    # lua
    ''
      hl.on("hyprland.start", function() hl.exec_cmd("${pkgs.quickshell}/bin/quickshell -p ${shell}") end)
    '';
}
