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

  terminal-spawn = cmd: "${lib.getExe config.programs.alacritty.package} -e /bin/sh -c \"${cmd}\"";

  systemMonitor = terminal-spawn "${config.programs.btop.package}/bin/btop";
  wiremix = terminal-spawn "${pkgs.wiremix}/bin/wiremix";

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
