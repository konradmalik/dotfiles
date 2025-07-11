{ colorscheme, wallpaper }:
let
  c = colorscheme.palette;
in
''
  general {
    gaps_in=5
    gaps_out=10
    border_size=2
    col.active_border=0xff${c.base0C}
    col.inactive_border=0xff${c.base02}
    col.nogroup_border_active=0xff${c.base0B}
    col.nogroup_border=0xff${c.base04}
    layout=dwindle
  }
  cursor {
    inactive_timeout=5
  }

  decoration {
    rounding = 10

    blur {
      enabled = false
    }
    shadow {
      ignore_window = true
      offset = 0 5
      range = 50
      render_power = 3
      color = rgba(00000099)
    }
  }

  animations {
    enabled = false
  }

  dwindle {
    # keep floating dimentions while tiling
    pseudotile = true
    preserve_split = true
  }

  misc {
    disable_autoreload = true
    animate_mouse_windowdragging = false
  }

  input {
    kb_layout=us,pl
    # left-to-right:
    # use both shofts together to toggle keyboard layout
    # capslock acts as another ctrl
    # left alt allows to write special characters just like right alt
    kb_options=grp:shifts_toggle,ctrl:nocaps
    # enable lalt_switch only on-demand via keybind below
    #kb_options=grp:shifts_toggle,ctrl:nocaps,lv3:lalt_switch

    natural_scroll=true

    touchpad {
      disable_while_typing=true
      natural_scroll=true
      tap-to-click=true
    }
  }

  device {
    name = elan-touchscreen
    enabled=false
  }

  gestures {
    workspace_swipe=true
  }

  # Startup
  exec=swaybg -i ${wallpaper} --mode fill
  exec-once=waybar
  exec-once=mako
  exec-once=swayidle -w

  # Mouse binding
  bindm=SUPER,mouse:272,movewindow
  bindm=SUPER,mouse:273,resizewindow

  # Keyboard alt behavior
  bind=SUPER,c,exec,hyprctl keyword input:kb_options grp:shifts_toggle,ctrl:nocaps,lv3:lalt_switch
  bind=SUPERSHIFT,c,exec,hyprctl keyword input:kb_options grp:shifts_toggle,ctrl:nocaps

  # Program bindings
  bind=SUPER,return,exec,$TERMINAL
  bind=SUPER,w,exec,makoctl dismiss
  bind=SUPER,b,exec,$BROWSER
  bind=SUPER,x,exec,wofi -S drun -x 10 -y 10 -W 25% -H 60%
  bind=SUPER,space,exec,wofi -S run

  # Screenshots
  bind=SUPER,p,exec,grim -g "$(slurp -d)" - | wl-copy -t image/png
  bind=SUPERSHIFT,p,exec,grim -g "$(slurp -d)" /tmp/$(date +'%H:%M:%S.png')

  # Keyboard controls (brightness, media, sound, etc)
  bind=,XF86MonBrightnessUp,exec,light -A 10
  bind=,XF86MonBrightnessDown,exec,light -U 10
  bind=,XF86AudioNext,exec,playerctl next
  bind=,XF86AudioPrev,exec,playerctl previous
  bind=,XF86AudioPlay,exec,playerctl play-pause
  bind=,XF86AudioStop,exec,playerctl stop
  bind=ALT,XF86AudioNext,exec,playerctld shift
  bind=ALT,XF86AudioPrev,exec,playerctld unshift
  bind=ALT,XF86AudioPlay,exec,systemctl --user restart playerctld
  bind=,XF86AudioRaiseVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ +5%
  bind=,XF86AudioLowerVolume,exec,pactl set-sink-volume @DEFAULT_SINK@ -5%
  bind=,XF86AudioMute,exec,pactl set-sink-mute @DEFAULT_SINK@ toggle
  bind=SHIFT,XF86AudioMute,exec,pactl set-source-mute @DEFAULT_SOURCE@ toggle
  bind=,XF86AudioMicMute,exec,pactl set-source-mute @DEFAULT_SOURCE@ toggle

  # Window manager controls
  bind=SUPERSHIFT,q,killactive
  bind=SUPERSHIFT,e,exit
  bind=SUPER,f,fullscreen,1
  bind=SUPERSHIFT,f,fullscreen,0
  bind=SUPERSHIFT,space,togglefloating
  bind=SUPER,minus,splitratio,-0.25
  bind=SUPERSHIFT,minus,splitratio,-0.3333333
  bind=SUPER,equal,splitratio,0.25
  bind=SUPERSHIFT,equal,splitratio,0.3333333

  # dwindle
  bind=SUPER,s,pseudo
  bind=SUPER,g,togglegroup
  bind=SUPER,apostrophe,changegroupactive,f
  bind=SUPERSHIFT,apostrophe,changegroupactive,b

  # rest
  bind=SUPER,left,movefocus,l
  bind=SUPER,right,movefocus,r
  bind=SUPER,up,movefocus,u
  bind=SUPER,down,movefocus,d
  bind=SUPER,h,movefocus,l
  bind=SUPER,l,movefocus,r
  bind=SUPER,k,movefocus,u
  bind=SUPER,j,movefocus,d
  bind=SUPERSHIFT,left,movewindow,l
  bind=SUPERSHIFT,right,movewindow,r
  bind=SUPERSHIFT,up,movewindow,u
  bind=SUPERSHIFT,down,movewindow,d
  bind=SUPERSHIFT,h,movewindow,l
  bind=SUPERSHIFT,l,movewindow,r
  bind=SUPERSHIFT,k,movewindow,u
  bind=SUPERSHIFT,j,movewindow,d
  bind=SUPERSHIFT,j,movewindow,d
  bind=SUPER,tab,cyclenext
  bind=SUPERSHIFT,tab,cyclenext,prev
  bind=SUPERCONTROL,tab,swapnext
  bind=SUPERCONTROLSHIFT,tab,swapnext,prev
  bind=SUPERCONTROL,left,focusmonitor,l
  bind=SUPERCONTROL,right,focusmonitor,r
  bind=SUPERCONTROL,up,focusmonitor,u
  bind=SUPERCONTROL,down,focusmonitor,d
  bind=SUPERCONTROL,h,focusmonitor,l
  bind=SUPERCONTROL,l,focusmonitor,r
  bind=SUPERCONTROL,k,focusmonitor,u
  bind=SUPERCONTROL,j,focusmonitor,d
  bind=SUPERCONTROLSHIFT,left,movewindow,mon:l
  bind=SUPERCONTROLSHIFT,right,movewindow,mon:r
  bind=SUPERCONTROLSHIFT,up,movewindow,mon:u
  bind=SUPERCONTROLSHIFT,down,movewindow,mon:d
  bind=SUPERCONTROLSHIFT,h,movewindow,mon:l
  bind=SUPERCONTROLSHIFT,l,movewindow,mon:r
  bind=SUPERCONTROLSHIFT,k,movewindow,mon:u
  bind=SUPERCONTROLSHIFT,j,movewindow,mon:d
  bind=SUPERALT,left,movecurrentworkspacetomonitor,l
  bind=SUPERALT,right,movecurrentworkspacetomonitor,r
  bind=SUPERALT,up,movecurrentworkspacetomonitor,u
  bind=SUPERALT,down,movecurrentworkspacetomonitor,d
  bind=SUPERALT,h,movecurrentworkspacetomonitor,l
  bind=SUPERALT,l,movecurrentworkspacetomonitor,r
  bind=SUPERALT,k,movecurrentworkspacetomonitor,u
  bind=SUPERALT,j,movecurrentworkspacetomonitor,d
  bind=SUPER,u,togglespecialworkspace
  bind=SUPERSHIFT,u,movetoworkspace,special
  bind=SUPER,1,workspace,01
  bind=SUPER,2,workspace,02
  bind=SUPER,3,workspace,03
  bind=SUPER,4,workspace,04
  bind=SUPER,5,workspace,05
  bind=SUPER,6,workspace,06
  bind=SUPER,7,workspace,07
  bind=SUPER,8,workspace,08
  bind=SUPER,9,workspace,09
  bind=SUPER,0,workspace,10
  bind=SUPERSHIFT,1,movetoworkspacesilent,01
  bind=SUPERSHIFT,2,movetoworkspacesilent,02
  bind=SUPERSHIFT,3,movetoworkspacesilent,03
  bind=SUPERSHIFT,4,movetoworkspacesilent,04
  bind=SUPERSHIFT,5,movetoworkspacesilent,05
  bind=SUPERSHIFT,6,movetoworkspacesilent,06
  bind=SUPERSHIFT,7,movetoworkspacesilent,07
  bind=SUPERSHIFT,8,movetoworkspacesilent,08
  bind=SUPERSHIFT,9,movetoworkspacesilent,09
  bind=SUPERSHIFT,0,movetoworkspacesilent,10
''
