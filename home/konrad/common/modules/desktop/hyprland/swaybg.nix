{
  swaybg,
  wallpaper,
  ...
}:
{
  wayland.windowManager.hyprland.settings.exec = [
    "${swaybg}/bin/swaybg -i ${wallpaper} --mode fill"
  ];
}
