{
  pkgs,
  ...
}:
{

  home.packages = [ pkgs.nwg-bar ];
  xdg.configFile = {
    "nwg-bar/hyprland.json".text =
      # json
      ''
        [
          {
            "label": "Lock",
            "exec": "loginctl lock-session",
            "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-lock-screen.svg"
          },
          {
            "label": "Exit",
            "exec": "hyprctl dispatch exit",
            "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-log-out.svg"
          },
          {
            "label": "Reboot",
            "exec": "systemctl reboot",
            "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-reboot.svg"
          },
          {
            "label": "Shutdown",
            "exec": "systemctl -i poweroff",
            "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-shutdown.svg"
          },
          {
            "label": "Reboot into firmware setup",
            "exec": "systemctl reboot --firmware-setup",
            "icon": "${pkgs.nwg-bar}/share/nwg-bar/images/system-reboot.svg"
          }
        ]
      '';
  };
}
