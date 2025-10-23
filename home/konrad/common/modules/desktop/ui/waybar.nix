{
  osConfig,
  config,
  pkgs,
  lib,
  ...
}:

let
  isLaptop = osConfig.programs.light.enable;

  playerctl = "${pkgs.playerctl}/bin/playerctl";
  playerctld = "${pkgs.playerctl}/bin/playerctld";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  btm = "${pkgs.bottom}/bin/btm";
  cal = "${pkgs.util-linux}/bin/cal";
  impala = "${pkgs.impala}/bin/impala";
  bluetui = "${pkgs.bluetui}/bin/bluetui";

  terminal-spawn = cmd: "${lib.getExe pkgs.alacritty} -e /bin/sh -c \"${cmd}\"";

  calendar = terminal-spawn "${cal} -3 && sleep infinity";
  systemMonitor = terminal-spawn btm;

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
  wayland.windowManager.hyprland.settings.exec-once = [ "waybar" ];
  stylix.targets.waybar.addCss = false;

  programs.waybar = {
    enable = true;
    settings = {
      primary = {
        layer = "top";
        position = "top";
        margin-top = 10;
        margin-left = 10;
        margin-right = 10;
        modules-left = [
          "custom/menu"
          "idle_inhibitor"
          "hyprland/workspaces"
          "custom/currentplayer"
          "custom/player"
        ];
        modules-center = [
          "cpu"
          "memory"
          "clock"
          "wireplumber"
        ]
        ++ (lib.optionals isLaptop [ "backlight" ])
        ++ [ "custom/hyprsunset" ];
        modules-right = [
          "privacy"
          "tray"
          "bluetooth"
          "network"
        ]
        ++ (lib.optionals isLaptop [ "battery" ])
        ++ [
          "hyprland/language"
          "user"
          "custom/powermenu"
        ];

        bluetooth = {
          format = "󰂯 ";
          format-disabled = "󰂲 ";
          format-connected = "󰂱 ";
          tooltip-format = "Devices connected: {num_connections}";
          on-click = terminal-spawn bluetui;
        };
        clock = {
          format = "{:L%d %B %H:%M}";
          tooltip-format = "<tt>{calendar}</tt>";
          on-click = calendar;
        };
        cpu = {
          format = "  {usage}%";
          on-click = systemMonitor;
        };
        memory = {
          format = "  {}%";
          interval = 5;
          on-click = systemMonitor;
        };
        wireplumber = {
          format = "{icon} {volume}% {format_source}";
          format-muted = "  -%";
          format-bluetooth = "{icon}󰂯 {volume}% {format_source}";
          format-bluetooth-muted = " 󰂯 -% {format_source}";
          format-source = "  {volume}%";
          format-source-muted = "  -%";
          format-icons = {
            headphone = " ";
            headset = "󰋎 ";
            hands-free = "󰋎 ";
            portable = " ";
            phone = " ";
            car = " ";
            default = [
              " "
              " "
              " "
            ];
          };
          on-click = pavucontrol;
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
          format = "{icon} {percent}%";
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
          on-scroll-up = "light -A 1";
          on-scroll-down = "light -U 1";
        };
        battery = {
          format = "{icon} {capacity}%";
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
            full = "󰂄";
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
        "custom/menu" = {
          return-type = "json";
          exec = jsonOutput "menu" {
            text = " ";
            tooltip = ''$(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f2)'';
          };
          on-click = "fuzzel";
        };
        "custom/powermenu" = {
          format = " ";
          tooltip-format = "{}";
          exec = "${pkgs.procps}/bin/uptime --pretty";
          interval = 60;
          on-click = "nwg-bar -t hyprland.json";
        };
        user = {
          format = "{user}";
          icon = true;
          avatar = "${config.home.homeDirectory}/.face";
          tooltip-format = "{}";
          exec = "groups";
          interval = 60;
        };
        "custom/hyprsunset" = {
          interval = 5;
          return-type = "json";
          exec = jsonOutput "hyprsunset" {
            pre = ''
              status="$(systemctl --user is-active hyprsunset)";
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
              player="$(${playerctl} status -f "{{playerName}}" 2>/dev/null || echo "No player active" | cut -d '.' -f1)"
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
          max-length = 30;
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
    # Cheatsheet:
    # x -> all sides
    # x y -> vertical, horizontal
    # x y z -> top, horizontal, bottom
    # w x y z -> top, right, bottom, left
    style =
      lib.mkAfter
        # css
        ''
          * {
            padding: 0 8px;
          }
          .modules-right {
            margin-right: -16px;
          }
          .modules-left {
            margin-left: -16px;
          }
          window#waybar {
            border-radius: 5px;
          }
          #workspaces button.active {
            background-color: @base09;
            color: @base00;
          }
          #clock {
            background-color: @base0D;
            color: @base00;
            padding: 0 16px;
            margin: 0 16px;
            border-radius: 5px;
          }
          #custom-menu {
            background-color: @base0D;
            color: @base00;
            padding-left: 15px;
            padding-right: 10px;
            border-radius: 5px;
            margin-right: 10px;
          }
          #custom-powermenu {
            background-color: @base08;
            color: @base00;
            padding-left: 10px;
            padding-right: 5px;
            border-radius: 5px;
          }
          #user {
            background-color: @base0D;
            color: @base00;
            padding: 0 5px;
            border-radius: 5px;
          }
          #privacy {
            background-color: @base08;
            color: @base00;
            border-radius: 5px;
          }
        '';
  };
}
