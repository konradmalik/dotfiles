{
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

  terminal-spawn = cmd: "${lib.getExe pkgs.alacritty} -e /bin/sh -c \"${cmd}\"";

  systemMonitor = terminal-spawn "${pkgs.btop}/bin/btop";
  wiremix = terminal-spawn "${pkgs.wiremix}/bin/wiremix";

  # Shared drawer config for hover-to-expand module groups.
  drawer = {
    transition-duration = 300;
    transition-left-to-right = true;
  };

  # Shared click actions for the volume group modules.
  volumeActions = {
    on-click = wiremix;
    on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
  };

  # Hover-to-expand group: collapsed shows the first module, the rest reveal on hover.
  drawerGroup = modules: {
    orientation = "horizontal";
    inherit drawer modules;
  };

  # Shared tooltip for the memory icon and its percentage reveal.
  memoryTooltip = "RAM {used:0.1f}/{total:0.1f} GiB ({percentage}%)";

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
          "hyprland/workspaces"
          "custom/currentplayer"
          "custom/player"
        ];
        modules-center = [
          "group/cpu"
          "group/memory"
          "clock"
          "group/volume"
        ]
        ++ (lib.optionals isLaptop [ "group/backlight" ]);
        modules-right = [
          "privacy"
          "tray"
          "bluetooth"
          "network"
        ]
        ++ (lib.optionals osConfig.services.tlp.pd.enable [
          "power-profiles-daemon"
        ])
        ++ (lib.optionals isLaptop [ "group/battery" ])
        ++ [
          "hyprland/language"
          "custom/hyprsunset"
          "idle_inhibitor"
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
          format = "{:%Y-%m-%d %H:%M}";
          tooltip-format = "<tt>{calendar}</tt>";
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            on-scroll = 1;
            format = {
              today = "<b>{}</b>";
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
        "cpu#text" = {
          format = "{usage}%";
          interval = 5;
        };
        memory = {
          format = " ";
          interval = 5;
          states = {
            warning = 70;
            critical = 90;
          };
          tooltip-format = memoryTooltip;
          on-click = systemMonitor;
        };
        "memory#text" = {
          format = "{percentage}%";
          interval = 5;
          tooltip-format = memoryTooltip;
        };
        "group/cpu" = drawerGroup [
          "cpu"
          "cpu#text"
        ];
        "group/memory" = drawerGroup [
          "memory"
          "memory#text"
        ];
        "group/volume" = drawerGroup [
          "wireplumber"
          "wireplumber#text"
        ];
        "group/backlight" = drawerGroup [
          "backlight"
          "backlight#text"
        ];
        "group/battery" = drawerGroup [
          "battery"
          "battery#text"
        ];
        wireplumber = volumeActions // {
          format = "{icon}";
          format-muted = " ";
          format-bluetooth = "{icon}󰂯";
          format-bluetooth-muted = " 󰂯";
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
        };
        "wireplumber#text" = volumeActions // {
          format = "{volume}%  {format_source}";
          format-source = " {volume}%";
          format-source-muted = " ";
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
          on-scroll-up = "brightnessctl set +1%";
          on-scroll-down = "brightnessctl set 1%-";
        };
        "backlight#text" = {
          format = "{percent}%";
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
        "battery#text" = {
          format = "{capacity}%";
          interval = 10;
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
          format = "{id}";
          on-click = "activate";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          persistent-workspaces = {
            "*" = 5;
          };
        };
        "hyprland/language" = {
          format = "{short}";
          on-click = "hyprctl switchxkblayout all next";
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
        "custom/hyprsunset" = {
          interval = 5;
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
