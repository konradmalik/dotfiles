{ colorscheme, wallpaper }: ''
  general {
    gaps_in=5
    gaps_out=10
    border_size=2.7
    col.active_border=0xff${colorscheme.colors.base0C}
    col.inactive_border=0xff${colorscheme.colors.base02}
    cursor_inactive_timeout=5
  }
  decoration {
    active_opacity=0.9
    inactive_opacity=0.8
    fullscreen_opacity=1.0
    rounding=5
    blur=true
    blur_size=6
    blur_passes=3
    blur_new_optimizations=true
    blur_ignore_opacity=true
    drop_shadow=true
    shadow_range=12
    shadow_offset=3 3
    col.shadow=0x44000000
    col.shadow_inactive=0x66000000
  }
  animations {
    enabled=true
    bezier=easein,0.11, 0, 0.5, 0
    bezier=easeout,0.5, 1, 0.89, 1
    bezier=easeinout,0.45, 0, 0.55, 1
    animation=windowsIn,1,2,easeout,slide
    animation=windowsOut,1,2,easein,slide
    animation=windowsMove,1,2,easeout
    animation=fadeIn,1,2,easeout
    animation=fadeOut,1,2,easein
    animation=fadeSwitch,1,2,easeout
    animation=fadeShadow,1,2,easeout
    animation=fadeDim,1,2,easeout
    animation=border,1,2,easeout
    animation=workspaces,1,2,easeout,slide
  }
  dwindle {
    col.group_border_active=0xff${colorscheme.colors.base0B}
    col.group_border=0xff${colorscheme.colors.base04}
    split_width_multiplier=1.35
  }
  misc {
    no_vfr=false
  }
  input {
    kb_layout=us,pl
    # left-to-right:
    # use both shofts together to toggle keyboard layout
    # capslock acts as another ctrl
    # left alt allows to write special characters just like right alt
    kb_options=grp:shifts_toggle,ctrl:nocaps,lv3:lalt_switch

    natural_scroll=true

    touchpad {
      disable_while_typing=true
      natural_scroll=true
      tap-to-click=true
    }
  }
  device:elan-touchscreen {
    enabled=false
  }
  gestures {
    workspace_swipe=true
  }
  # Startup
  exec-once=waybar
  exec=swaybg -i ${wallpaper} --mode fill
  exec-once=mako
  exec-once=swayidle -w
  # Mouse binding
  bindm=SUPER,mouse:272,movewindow
  bindm=SUPER,mouse:273,resizewindow
  # Program bindings
  bind=SUPER,Return,exec,$TERMINAL
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
  bind=SUPER,g,togglegroup
  bind=SUPER,apostrophe,changegroupactive,f
  bind=SUPERSHIFT,apostrophe,changegroupactive,b
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
  blurls=waybar
''
