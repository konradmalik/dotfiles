{ osConfig, lib, ... }:
let
  isLaptop = osConfig.services.upower.enable;

  inline = lib.generators.mkLuaInline;
  mkBind = keys: disp: { _args = [ keys (inline disp) ]; };
  mkBindF = keys: disp: flags: { _args = [ keys (inline disp) flags ]; };

  mouseFlag = { mouse = true; };
  lockedFlag = { locked = true; };
  audioFlag = {
    repeating = true;
    locked = true;
  };

  exec = cmd: ''hl.dsp.exec_cmd("${cmd}")'';

  workspaceBinds = lib.concatMap (n: [
    (mkBind "SUPER + ${toString n}" ''hl.dsp.focus({ workspace = ${toString n} })'')
    (mkBind "SUPER + SHIFT + ${toString n}" ''hl.dsp.window.move({ workspace = ${toString n}, follow = false })'')
  ]) [ 1 2 3 4 5 6 7 8 9 ];

  # workspace 10 uses key "0"
  workspace10Binds = [
    (mkBind "SUPER + 0" ''hl.dsp.focus({ workspace = 10 })'')
    (mkBind "SUPER + SHIFT + 0" ''hl.dsp.window.move({ workspace = 10, follow = false })'')
  ];

  directionalBinds = lib.concatMap (
    { key, dir }:
    [
      (mkBind "SUPER + ${key}" ''hl.dsp.focus({ direction = "${dir}" })'')
      (mkBind "SUPER + SHIFT + ${key}" ''hl.dsp.window.move({ direction = "${dir}" })'')
      (mkBind "SUPER + CTRL + ${key}" ''hl.dsp.focus({ monitor = "${dir}" })'')
      (mkBind "SUPER + CTRL + SHIFT + ${key}" ''hl.dsp.window.move({ monitor = "${dir}" })'')
      (mkBind "SUPER + ALT + ${key}" ''hl.dsp.workspace.move({ monitor = "${dir}" })'')
    ]
  ) [
    { key = "left"; dir = "l"; }
    { key = "right"; dir = "r"; }
    { key = "up"; dir = "u"; }
    { key = "down"; dir = "d"; }
    { key = "h"; dir = "l"; }
    { key = "l"; dir = "r"; }
    { key = "k"; dir = "u"; }
    { key = "j"; dir = "d"; }
  ];
in
{
  wayland.windowManager.hyprland.settings.bind = [
    # Mouse
    (mkBindF "SUPER + mouse:272" "hl.dsp.window.drag()" mouseFlag)
    (mkBindF "SUPER + mouse:273" "hl.dsp.window.resize()" mouseFlag)

    # Audio (repeating + locked so it works during long-press and on lock screen)
    (mkBindF "XF86AudioRaiseVolume" (exec "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+") audioFlag)
    (mkBindF "XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") audioFlag)
    (mkBindF "XF86AudioMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") audioFlag)
    (mkBindF "XF86AudioMicMute" (exec "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") audioFlag)

    # Media (locked so it works on lock screen)
    (mkBindF "XF86AudioNext" (exec "playerctl next") lockedFlag)
    (mkBindF "XF86AudioPause" (exec "playerctl play-pause") lockedFlag)
    (mkBindF "XF86AudioPlay" (exec "playerctl play-pause") lockedFlag)
    (mkBindF "XF86AudioPrev" (exec "playerctl previous") lockedFlag)
    (mkBindF "XF86AudioStop" (exec "playerctl stop") lockedFlag)

    # Keyboard alt behavior
    (mkBind "SUPER + c" (exec "hyprctl keyword input:kb_options grp:shifts_toggle,ctrl:nocaps,lv3:lalt_switch"))
    (mkBind "SUPER + SHIFT + c" (exec "hyprctl keyword input:kb_options grp:shifts_toggle,ctrl:nocaps"))

    # Program bindings
    (mkBind "SUPER + return" (exec "$TERMINAL"))
    (mkBind "SUPER + w" (exec "makoctl dismiss"))
    (mkBind "SUPER + b" (exec "$BROWSER"))
    (mkBind "SUPER + space" (exec "fuzzel"))

    # Screenshots
    # NOTE: killall is useful for occasional freezes of hyprpicker
    # just try to screenshot again and it should unfreeze
    (mkBind "SUPER + p" (exec "killall hyprpicker ; hyprshot --freeze --mode region --output /tmp/screenshots"))
    (mkBind "SUPER + SHIFT + p" (exec "killall hyprpicker ; hyprshot --freeze --raw --mode region --clipboard-only | swappy -f -"))

    # Window manager controls
    (mkBind "SUPER + SHIFT + q" "hl.dsp.window.close()")
    (mkBind "SUPER + SHIFT + e" "hl.dsp.exit()")
    (mkBind "SUPER + f" ''hl.dsp.window.fullscreen({ mode = "maximized" })'')
    (mkBind "SUPER + SHIFT + f" ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')
    (mkBind "SUPER + SHIFT + space" "hl.dsp.window.float()")
    (mkBind "SUPER + minus" ''hl.dsp.layout("splitratio -0.25")'')
    (mkBind "SUPER + SHIFT + minus" ''hl.dsp.layout("splitratio -0.3333333")'')
    (mkBind "SUPER + equal" ''hl.dsp.layout("splitratio 0.25")'')
    (mkBind "SUPER + SHIFT + equal" ''hl.dsp.layout("splitratio 0.3333333")'')

    # dwindle
    (mkBind "SUPER + s" "hl.dsp.window.pseudo()")
    (mkBind "SUPER + g" "hl.dsp.group.toggle()")
    (mkBind "SUPER + apostrophe" "hl.dsp.group.next()")
    (mkBind "SUPER + SHIFT + apostrophe" "hl.dsp.group.prev()")

    # Window/workspace/monitor cycling
    (mkBind "SUPER + tab" "hl.dsp.window.cycle_next()")
    (mkBind "SUPER + SHIFT + tab" "hl.dsp.window.cycle_next({ next = false })")
    (mkBind "SUPER + CTRL + tab" "hl.dsp.window.swap({ next = true })")
    (mkBind "SUPER + CTRL + SHIFT + tab" "hl.dsp.window.swap({ prev = true })")

    # Special workspace
    (mkBind "SUPER + u" ''hl.dsp.workspace.toggle_special("")'')
    (mkBind "SUPER + SHIFT + u" ''hl.dsp.window.move({ workspace = "special" })'')
  ]
  ++ directionalBinds
  ++ workspaceBinds
  ++ workspace10Binds
  ++ lib.optionals isLaptop [
    (mkBindF "XF86MonBrightnessUp" (exec "brightnessctl set +10%") audioFlag)
    (mkBindF "XF86MonBrightnessDown" (exec "brightnessctl set 10%-") audioFlag)
  ];
}
