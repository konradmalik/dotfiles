{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:

let
  isLaptop = osConfig.services.upower.enable;

  playerctl = "${pkgs.playerctl}/bin/playerctl";
  playerctld = "${pkgs.playerctl}/bin/playerctld";
  impala = "${pkgs.impala}/bin/impala";
  bluetui = "${pkgs.bluetui}/bin/bluetui";

  makoctl = "${config.services.mako.package}/bin/makoctl";
  fuzzel = "${config.programs.fuzzel.package}/bin/fuzzel";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  refreshWaybar = "${pkgs.procps}/bin/pkill -RTMIN+8 waybar";
  refreshTailscale = "${pkgs.procps}/bin/pkill -RTMIN+9 waybar";

  terminal-spawn = cmd: "${lib.getExe config.programs.alacritty.package} -e /bin/sh -c \"${cmd}\"";

  systemMonitor = terminal-spawn "${config.programs.btop.package}/bin/btop";
  wiremix = terminal-spawn "${pkgs.wiremix}/bin/wiremix";

  colors = config.lib.stylix.colors.withHashtag;

  tailscale = "${osConfig.services.tailscale.package}/bin/tailscale";
  # the tailscale mark: nine dots, the five solid ones drawing the "t". no font
  # carries it, so it is rendered to a png and pulled in as a css background
  tailscaleIcon =
    name: color:
    let
      svg = pkgs.writeText "tailscale-${name}.svg" ''
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="${color}">
          <circle cx="4.5" cy="4.5" r="2.9"/>
          <circle cx="12" cy="4.5" r="2.9"/>
          <circle cx="19.5" cy="4.5" r="2.9"/>
          <circle cx="12" cy="12" r="2.9"/>
          <circle cx="12" cy="19.5" r="2.9"/>
          <circle cx="4.5" cy="12" r="2.9" opacity="0.35"/>
          <circle cx="19.5" cy="12" r="2.9" opacity="0.35"/>
          <circle cx="4.5" cy="19.5" r="2.9" opacity="0.35"/>
          <circle cx="19.5" cy="19.5" r="2.9" opacity="0.35"/>
        </svg>
      '';
    in
    pkgs.runCommand "tailscale-${name}.png" { nativeBuildInputs = [ pkgs.librsvg ]; } ''
      rsvg-convert --width 64 --height 64 ${svg} --output $out
    '';
  tailscaleCopyIp = pkgs.writeShellScript "waybar-tailscale-copy-ip" ''
    set -euo pipefail
    ip="$(${tailscale} ip -4 2>/dev/null)" || ip=""
    # piping straight into wl-copy would clear the clipboard when down
    if [ -n "$ip" ]; then
      printf '%s' "$ip" | ${wl-copy}
    else
      ${pkgs.libnotify}/bin/notify-send "Tailscale" "No address to copy"
    fi
  '';
  # up/down need the operator bit granted in hosts/common/modules/tailscale.nix
  tailscaleToggle = pkgs.writeShellScript "waybar-tailscale-toggle" ''
    set -euo pipefail
    state="$(${tailscale} status --json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.BackendState // ""')" || state=""

    notify() { ${pkgs.libnotify}/bin/notify-send --urgency critical "Tailscale" "$1"; }

    case "$state" in
      Running)
        out="$(${tailscale} down 2>&1)" || notify "$out"
        ;;
      NeedsLogin)
        # up prints a login url and then waits for the browser, so this one has
        # to happen somewhere the url is actually readable
        ${terminal-spawn "${tailscale} up"}
        ;;
      *)
        # up blocks forever by default, and it refuses outright when prefs were
        # set with non-default flags, so bound it and surface whatever it said
        out="$(${tailscale} up --timeout 30s 2>&1)" || notify "$out"
        ;;
    esac
    ${refreshTailscale} || true
  '';

  # Function to simplify making waybar outputs
  jsonOutput =
    name:
    {
      pre ? "",
      text ? "",
      tooltip ? "",
      alt ? "",
      class ? "",
      percentage ? "",
    }:
    "${pkgs.writeShellScriptBin "waybar-${name}" ''
      set -euo pipefail
      ${pre}
      ${pkgs.jq}/bin/jq -cn \
        --arg text "${text}" \
        --arg tooltip "${tooltip}" \
        --arg alt "${alt}" \
        --arg class "${class}" \
        --arg percentage "${percentage}" \
        '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
    ''}/bin/waybar-${name}";
in
{
  wayland.windowManager.hyprland.extraConfig = ''
    hl.on("hyprland.start", function() hl.exec_cmd("waybar") end)
  '';
  stylix.targets.waybar.addCss = false;

  # waybar.css refers to these by relative url, which gtk resolves next to the
  # stylesheet, so they have to land in the same directory
  xdg.configFile = lib.optionalAttrs osConfig.services.tailscale.enable {
    "waybar/tailscale-connected.png".source = tailscaleIcon "connected" colors.base0D;
    "waybar/tailscale-needs-login.png".source = tailscaleIcon "needs-login" colors.base0A;
    "waybar/tailscale-off.png".source = tailscaleIcon "off" colors.base04;
  };
  services.mako.settings.on-notify = "exec ${refreshWaybar}";

  programs.waybar = {
    enable = true;
    settings = {
      primary = {
        layer = "top";
        position = "top";
        modules-left = [
          "custom/menu"
          "hyprland/workspaces"
          "custom/currentplayer"
          "custom/player"
        ];
        modules-center = [
          "custom/notifications"
          "clock"
          "privacy"
        ];
        modules-right = [
          "tray"
          "bluetooth"
          "wireplumber"
        ]
        ++ (lib.optionals osConfig.services.tailscale.enable [
          "custom/tailscale"
        ])
        ++ [
          "network"
          "hyprland/language"
          "cpu"
          "memory"
        ]
        ++ (lib.optionals osConfig.services.tlp.pd.enable [
          "power-profiles-daemon"
        ])
        ++ (lib.optionals isLaptop [
          "battery"
          "backlight"
        ])
        ++ [
          "custom/hyprsunset"
          "idle_inhibitor"
          "custom/powermenu"
        ];

        tray = {
          spacing = 6;
        };
        bluetooth = {
          format = " 󰂯 ";
          format-disabled = " 󰂲 ";
          format-connected = " 󰂱 ";
          tooltip-format = "Devices connected: {num_connections}";
          on-click = terminal-spawn bluetui;
        };
        clock = {
          format = "{:%Y-%m-%d %H:%M}";
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            on-scroll = 1;
            format = {
              today = "<b><u>{}</u></b>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
        cpu = {
          format = " ";
          interval = 5;
          states = {
            warning = 70;
            critical = 90;
          };
          tooltip-format = "CPU {usage}%";
          on-click = systemMonitor;
        };
        memory = {
          format = " ";
          interval = 5;
          states = {
            warning = 70;
            critical = 90;
          };
          tooltip-format = "RAM {used:0.1f}/{total:0.1f} GiB ({percentage}%)";
          on-click = systemMonitor;
        };
        wireplumber = {
          format = "{icon}";
          format-muted = " ";
          format-source = " {volume}%";
          format-source-muted = " ";
          format-icons = [
            " "
            " "
            " "
          ];
          scroll-step = 5;
          tooltip-format = "Output: {node_name}\nInput: {source_desc}\n{icon} {volume}%  {format_source}";
          on-click = wiremix;
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰒳 ";
            deactivated = "󰒲 ";
          };
        };
        backlight = {
          format = "{icon}";
          tooltip-format = "Brightness {percent}%";
          format-icons = [
            " "
            " "
            " "
            " "
            " "
            " "
            " "
            " "
            " "
          ];
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };
        battery = {
          format = "{icon}";
          format-icons = {
            plugged = "";
            charging = [
              "󰢜 "
              "󰂆 "
              "󰂇 "
              "󰂈 "
              "󰢝 "
              "󰂉 "
              "󰢞 "
              "󰂊 "
              "󰂋 "
              "󰂅 "
            ];
            default = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
          };
          tooltip-format-discharging = "{power:>1.0f}W↓ {capacity}% {timeTo}";
          tooltip-format-charging = "{power:>1.0f}W↑ {capacity}% {timeTo}";
          interval = 10;
          on-click = "";
          states = {
            full = 95;
            good = 50;
            warning = 30;
            critical = 15;
          };
        };
        power-profiles-daemon = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          format-icons = {
            default = "󰾅 ";
            performance = "󰓅 ";
            balanced = "󰾅 ";
            power-saver = "󰌪 ";
          };
        };
        network = {
          format-icons = [
            "󰤯 "
            "󰤟 "
            "󰤢 "
            "󰤥 "
            "󰤨 "
          ];
          interval = 5;
          format-wifi = "{icon} {essid}";
          format-ethernet = "󰈀 ";
          format-disconnected = "󰤭 ";
          format-linked = "  {ifname} (No IP)";
          tooltip-format = ''
            {ifname}
            {ipaddr}/{cidr}
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}'';
          on-click = terminal-spawn impala;
        };
        "hyprland/workspaces" = {
          format = "{icon}";
          cursor = true;
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
            "10" = "0";
            active = "󱓻";
            default = "";
          };
          persistent-workspaces = {
            "1" = { };
            "2" = { };
            "3" = { };
            "4" = { };
            "5" = { };
          };
          on-click = "activate";
          on-scroll-up = "hyprctl dispatch 'hl.dsp.focus({workspace = \"e+1\"})'";
          on-scroll-down = "hyprctl dispatch 'hl.dsp.focus({workspace = \"e-1\"})'";
        };
        "hyprland/language" = {
          format = "{short}";
          on-click = "hyprctl switchxkblayout all next";
        };
        "custom/tailscale" = {
          interval = 10;
          signal = 9;
          return-type = "json";
          exec = jsonOutput "tailscale" {
            pre = ''
              # reading the status needs no operator bit, tailscaled hands every
              # local user read-only access. the cli does exit non-zero in some
              # states while still printing usable json, so only the json counts
              status="$(${tailscale} status --json 2>/dev/null)" || true
              ${pkgs.jq}/bin/jq -e . >/dev/null 2>&1 <<<"$status" || status="{}"
              state="$(${pkgs.jq}/bin/jq -r '.BackendState // "NoState"' <<<"$status")"
              host="$(${pkgs.jq}/bin/jq -r '.Self.HostName // "?"' <<<"$status")"
              ip="$(${pkgs.jq}/bin/jq -r '.TailscaleIPs[0]? // "no address"' <<<"$status")"
              case "$state" in
                Running) class="connected" ;;
                Stopped) class="stopped" ;;
                NeedsLogin) class="needs-login" ;;
                *) class="down" ;;
              esac

              tooltip="Tailscale: $state"$'\n'"$host ($ip)"
            '';
            class = "$class";
            tooltip = "$tooltip";
          };
          # the icon is a css background, but waybar hides a custom module whose
          # text is empty, so the label is a space holding the space open
          format = " ";
          on-click = "${tailscaleToggle}";
          on-click-right = "${tailscaleCopyIp}";
        };
        "custom/menu" = {
          format = "  ";
          tooltip-format = "${osConfig.system.nixos.distroName} ${osConfig.system.nixos.version} (${osConfig.system.nixos.codeName})";
          on-click = "fuzzel";
        };
        "custom/notifications" = {
          return-type = "json";
          interval = 5;
          signal = 8;
          exec = jsonOutput "notifications" {
            pre = ''
              notifs="$(${makoctl} list -j)"
              count="$(${pkgs.jq}/bin/jq 'length' <<<"$notifs")"
              list="$(${pkgs.jq}/bin/jq -r '.[] | "• \(.summary)"' <<<"$notifs")"
              if ${makoctl} mode | grep -qx do-not-disturb; then
                state="dnd"
                tooltip="Do not disturb"
              elif [ "$count" -gt 0 ]; then
                state="active"
                tooltip="$count notification(s)"
              else
                state="none"
                tooltip="No notifications"
              fi
              [ -n "$list" ] && tooltip="$tooltip"$'\n'"$list"
              [ "$count" -gt 0 ] && badge=" $count" || badge=""
            '';
            alt = "$state";
            class = "$state";
            text = "$badge";
            tooltip = "$tooltip";
          };
          format = "{icon}{text}";
          format-icons = {
            none = "󰂚 ";
            active = "󱅫 ";
            dnd = "󰂛 ";
          };
          on-click = ''${makoctl} history -j | ${pkgs.jq}/bin/jq -r '.[] | "\(.summary) — \(.body)"' | ${fuzzel} --dmenu --prompt "notifications> " | ${wl-copy}'';
          on-click-right = "${makoctl} dismiss --all; ${refreshWaybar}";
          on-click-middle = "${makoctl} mode -t do-not-disturb; ${refreshWaybar}";
          on-scroll-up = "${makoctl} restore; ${refreshWaybar}";
          on-scroll-down = "${makoctl} dismiss; ${refreshWaybar}";
        };
        "custom/powermenu" = {
          format = " ";
          tooltip-format = "{}";
          exec = "${pkgs.procps}/bin/uptime --pretty";
          interval = 60;
          on-click = "nwg-bar -t hyprland.json";
        };
        "custom/hyprsunset" = {
          interval = 30;
          return-type = "json";
          exec = jsonOutput "hyprsunset" {
            pre = ''
              status="$(systemctl --user is-active hyprsunset || true)";
            '';
            alt = "\${status:-inactive}";
            tooltip = "hyprsunset is $status";
          };
          format = "{icon}";
          format-icons = {
            "inactive" = "󱓤 ";
            "active" = "󱁞 ";
            "failed" = " ";
            "activating" = " ";
            "deactivating" = " ";
            "maintenance" = "󱤴 ";
            "reloading" = "󰑓 ";
            "refreshing" = "󰑓 ";
          };
          on-click = "systemctl --user is-active hyprsunset && systemctl --user stop hyprsunset || systemctl --user start hyprsunset";
        };
        "custom/currentplayer" = {
          interval = 2;
          return-type = "json";
          exec = jsonOutput "currentplayer" {
            pre = ''
              player="$(${playerctl} status -f "{{playerName}}" 2>/dev/null || echo "No player active")"
              # strip any .instance suffix; | binds tighter than ||, so this cannot
              # live on the same line as the fallback
              player="''${player%%.*}"
              count="$(${playerctl} -l | wc -l)"
              if ((count > 1)); then
                more=" +$((count - 1))"
              else
                more=""
              fi
            '';
            alt = "$player";
            tooltip = "$player ($count available)";
            text = "$more";
          };
          format = "{icon}{text}";
          format-icons = {
            "No player active" = "󰝛 ";
            "spotify" = " ";
            "firefox" = " ";
            "discord" = "󰙯 ";
          };
          on-click = "${playerctld} shift";
          on-click-right = "${playerctld} unshift";
        };
        "custom/player" = {
          exec-if = "${playerctl} status";
          exec = ''${playerctl} metadata --format '{"text": "{{artist}} - {{title}}", "alt": "{{status}}", "tooltip": "{{title}} ({{artist}} - {{album}})"}' '';
          return-type = "json";
          interval = 2;
          max-length = 50;
          format = "{icon} {text}";
          format-icons = {
            "Playing" = " ";
            "Paused" = " ";
            "Stopped" = "";
          };
          on-click = "${playerctl} play-pause";
        };
      };
    };
    style = lib.mkAfter (builtins.readFile ./waybar.css);
  };
}
