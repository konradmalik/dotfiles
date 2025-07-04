{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.lib) optionals;

  # Dependencies
  jq = "${pkgs.jq}/bin/jq";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  journalctl = "${pkgs.systemd}/bin/journalctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  playerctld = "${pkgs.playerctl}/bin/playerctld";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  btm = "${pkgs.bottom}/bin/btm";
  wofi = "${pkgs.wofi}/bin/wofi";
  cal = "${pkgs.util-linux}/bin/cal";

  terminal = "${pkgs.alacritty}/bin/alacritty";
  terminal-spawn = cmd: "${terminal} -e $SHELL -i -c \"${cmd}\"";

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
      ${jq} -cn \
        --arg text "${text}" \
        --arg tooltip "${tooltip}" \
        --arg alt "${alt}" \
        --arg class "${class}" \
        --arg percentage "${percentage}" \
        '{text:$text,tooltip:$tooltip,alt:$alt,class:$class,percentage:$percentage}'
    ''}/bin/waybar-${name}";
in
{
  programs.waybar = {
    enable = true;
    settings = {
      secondary = {
        output = builtins.map (m: m.name) (builtins.filter (m: !m.isPrimary) config.monitors);
        layer = "top";
        margin-top = 10;
        margin-left = 10;
        margin-right = 10;
        height = 30;
        position = "top";
        modules-center = (
          lib.optionals config.wayland.windowManager.hyprland.enable [ "hyprland/workspaces" ]
        );

        "hyprland/workspaces" = {
          format = "{icon}";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          on-click = "activate";
        };
      };

      primary = {
        output = builtins.map (m: m.name) (builtins.filter (m: m.isPrimary) config.monitors);
        layer = "top";
        position = "top";
        margin-top = 10;
        margin-left = 10;
        margin-right = 10;
        height = 30;
        modules-left =
          [
            "custom/menu"
            "idle_inhibitor"
          ]
          ++ (optionals config.wayland.windowManager.hyprland.enable [ "hyprland/workspaces" ])
          ++ [
            "custom/currentplayer"
            "custom/player"
          ];
        modules-center = [
          "cpu"
          "memory"
          "clock"
          "pulseaudio"
          "backlight"
          "custom/gammastep"
        ];
        modules-right = [
          "tray"
          "network"
          "battery"
          "hyprland/language"
          "custom/hostname"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          on-click = "activate";
        };
        clock = {
          format = "{:%d/%m %H:%M}";
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
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
        pulseaudio = {
          format = "{icon} {volume}% {format_source}";
          format-muted = "  {icon} 0%";
          format-bluetooth = "{icon} {volume}% {format_source}";
          format-bluetooth-muted = "  {icon} 0% {format_source}";
          format-source = "  {volume}%";
          format-source-muted = "  0%";
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
          bat = "BAT1";
          interval = 20;
          format-icons = [
            " "
            " "
            " "
            " "
            " "
          ];
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰚥 {capacity}% ";
          states = {
            full = 95;
            good = 50;
            warning = 30;
            critical = 15;
          };
          onclick = "";
        };
        network = {
          interval = 3;
          format-wifi = "  {essid}";
          format-ethernet = "󰈀 Connected";
          format-disconnected = "󰖪 Disconnected";
          format-linked = "  {ifname} (No IP)";
          tooltip-format = ''
            {ifname}
            {ipaddr}/{cidr}
            Up: {bandwidthUpBits}
            Down: {bandwidthDownBits}'';
          on-click = "";
        };
        "custom/menu" = {
          return-type = "json";
          exec = jsonOutput "menu" {
            text = "";
            tooltip = ''$(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f2)'';
          };
          on-click = "${wofi} -S drun -x 10 -y 10 -W 25% -H 60%";
        };
        "custom/hostname" = {
          exec = "echo $USER@$(hostname)";
          on-click = terminal;
        };
        "custom/gammastep" = {
          interval = 5;
          return-type = "json";
          exec = jsonOutput "gammastep" {
            pre = ''
              if unit_status="$(${systemctl} --user is-active gammastep)"; then
                status="$unit_status ($(${journalctl} --user -u gammastep.service -g 'Period: ' | tail -1 | cut -d ':' -f6 | xargs))"
              else
                status="$unit_status"
              fi
            '';
            alt = "\${status:-inactive}";
            tooltip = "Gammastep is $status";
          };
          format = "{icon}";
          format-icons = {
            "activating" = "󰖛 ";
            "deactivating" = "󰖜 ";
            "inactive" = "? ";
            "active (Night)" = " ";
            "active (Nighttime)" = " ";
            "active (Transition (Night)" = " ";
            "active (Transition (Nighttime)" = " ";
            "active (Day)" = " ";
            "active (Daytime)" = " ";
            "active (Transition (Day)" = " ";
            "active (Transition (Daytime)" = " ";
          };
          on-click = "${systemctl} --user is-active gammastep && ${systemctl} --user stop gammastep || ${systemctl} --user start gammastep";
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
          format = "{icon}{}";
          format-icons = {
            "No player active" = " ";
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
          format = "{icon} {}";
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
      let
        c = config.colorscheme.palette;
      in
      # css
      ''
        * {
          font-family: ${config.fontProfiles.regular.family}, ${config.fontProfiles.monospace.family};
          font-size: ${toString (builtins.floor config.fontProfiles.regular.size)}pt;
          padding: 0 8px;
        }
        .modules-right {
          margin-right: -15px;
        }
        .modules-left {
          margin-left: -15px;
        }
        window#waybar.top {
          opacity: 0.95;
          padding: 0;
          background-color: #${c.base00};
          border: 2px solid #${c.base0C};
          border-radius: 10px;
        }
        window#waybar.bottom {
          opacity: 0.90;
          background-color: #${c.base00};
          border: 2px solid #${c.base0C};
          border-radius: 10px;
        }
        window#waybar {
          color: #${c.base05};
        }
        #workspaces button {
          background-color: #${c.base01};
          color: #${c.base05};
          margin: 4px;
        }
        #workspaces button.hidden {
          background-color: #${c.base00};
          color: #${c.base04};
        }
        #workspaces button.focused,
        #workspaces button.active {
          background-color: #${c.base0A};
          color: #${c.base00};
        }
        #clock {
          background-color: #${c.base0C};
          color: #${c.base00};
          padding-left: 15px;
          padding-right: 15px;
          margin-top: 0;
          margin-bottom: 0;
          border-radius: 10px;
        }
        #custom-menu {
          background-color: #${c.base0C};
          color: #${c.base00};
          padding-left: 15px;
          padding-right: 22px;
          margin-left: 0;
          margin-right: 10px;
          margin-top: 0;
          margin-bottom: 0;
          border-radius: 10px;
        }
        #custom-hostname {
          background-color: #${c.base0C};
          color: #${c.base00};
          padding-left: 15px;
          padding-right: 18px;
          margin-right: 0;
          margin-top: 0;
          margin-bottom: 0;
          border-radius: 10px;
        }
        #tray {
          color: #${c.base05};
        }
      '';
  };
}
