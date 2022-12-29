{ pkgs, lib, ... }:
{
  # Setup the sway config using home-manager
  home.wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    config = {
      assigns =
        let
          assign = n: id: { "${toString n}" = [ id ]; };
        in
        assign 4 { class = "Spotify"; } //
        assign 9 { app_id = "zoom"; } //
        assign 10 { class = "Slack"; };
      bars = [{ command = "waybar"; }];
      fonts = {
        #names = [ "Font Awesome 5 Free" "SF Pro Display" ];
        size = 11.0;
      };
      gaps.inner = 20;
      input."type:keyboard" = {
        xkb_layout = "us,pl";
        xkb_variant = ",qwerty";
        xkb_options = "grp:alt_caps_toggle";
        xkb_numlock = "enabled";
      };
      input."type:touchpad" = {
        tap = "enabled";
        natural_scroll = "enabled";
        scroll_method = "two_finger";
      };
      keybindings =
        let
          processScreenshot = ''wl-copy -t image/png && notify-send "Screenshot taken"'';
        in
        lib.mkOptionDefault {
          # Control volume
          XF86AudioRaiseVolume = "exec pactl set-sink-volume @DEFAULT_SINK@ +10%";
          XF86AudioLowerVolume = "exec pactl set-sink-volume @DEFAULT_SINK@ -10%";
          XF86AudioMute = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          XF86AudioMicMute = "exec pactl set-source-mute @DEFAULT_SOURCE@ toggle";
          # Control media
          XF86AudioPlay = "exec playerctl play-pause";
          XF86AudioPause = "exec playerctl play-pause";
          XF86AudioNext = "exec playerctl next";
          XF86AudioPrev = "exec playerctl previous";
          # Control brightness
          XF86MonBrightnessUp = "exec light -A 10";
          XF86MonBrightnessDown = "exec light -U 10";
          # Screenshot
          "$mod+Print" = ''exec grim - | ${processScreenshot}'';
          "$mod+Shift+Print" = ''exec grim -g "$(slurp -d)" - | ${processScreenshot}'';
          # Shortcuts for easier navigation between workspaces
          "$mod+Control+Left" = "workspace prev";
          "$mod+Control+l" = "workspace prev";
          "$mod+Control+Right" = "workspace next";
          "$mod+Control+h" = "workspace next";
          "$mod+Tab" = "workspace back_and_forth";
        };
      #menu = config.modules.desktop.apps.menu.${cfg.menu}.executable;
      modifier = "Mod4";
      #output."*" = { bg = "${cfg.wallpaper} fill"; };
      startup = [
        { command = "lock"; }
        { command = "autotiling"; }
        #{ command = "${udiskie}/bin/udiskie -s --appindicator --menu-update-workaround -f ${pkgs.pcmanfm}/bin/pcmanfm"; }
        { command = "import-gsettings"; always = true; }
        { command = "mako"; }
      ];
      terminal = "${pkgs.alacritty}";
      window.border = 0;
      window.commands =
        let
          rule = command: criteria: { command = command; criteria = criteria; };
          floatingNoBorder = criteria: rule "floating enable, border none" criteria;
        in
        [
          (rule "floating enable, sticky enable, resize set 384 216, move position 1516 821" { app_id = "firefox"; title = "^Picture-in-Picture$"; })
          (rule "floating enable, resize set 1000 600" { app_id = "zoom"; title = "^(?!Zoom Meeting$)"; })
          (floatingNoBorder { app_id = "ulauncher"; })
        ];
    };
    # extraConfig = ''
    #   seat seat0 xcursor_theme "${config.modules.desktop.gtk.cursorTheme.name}" ${toString config.modules.desktop.gtk.cursorTheme.size}
    # '';
    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=sway
      export XDG_CURRENT_DESKTOP=sway
    '';
  };
}
