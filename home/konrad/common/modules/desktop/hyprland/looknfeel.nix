{
  config,
}:
let
  c = config.colorscheme.palette;

  hexToRgba =
    hex: alpha:
    let
    in
    "rgba(${hex}${alpha})";

  inactiveBorder = hexToRgba c.base09 "aa";
  activeBorder = hexToRgba c.base0D "aa";
in
{
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 2;

      "col.active_border" = activeBorder;
      "col.inactive_border" = inactiveBorder;

      resize_on_border = false;
      allow_tearing = false;

      layout = "dwindle";
    };

    decoration = {
      rounding = 4;

      shadow.enabled = false;
      blur.enabled = false;
    };

    animations.enabled = false;

    dwindle = {
      pseudotile = true;
      preserve_split = true;
      force_split = 2;
    };

    misc = {
      animate_mouse_windowdragging = false;
      disable_autoreload = true;
      disable_hyprland_logo = true;
      disable_splash_rendering = true;
    };
  };
}
