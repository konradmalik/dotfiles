{
  wayland.windowManager.hyprland.settings = {
    input = {
      kb_layout = "us,pl";
      # left-to-right:
      # use both shofts together to toggle keyboard layout
      # capslock acts as another ctrl
      # left alt allows to write special characters just like right alt
      kb_options = "grp:shifts_toggle,ctrl:nocaps";

      natural_scroll = true;

      touchpad = {
        disable_while_typing = true;
        natural_scroll = true;
        tap-to-click = true;
      };
    };

    device = {
      name = "elan-touchscreen";
      enabled = false;
    };

    gesture = [ "3, horizontal, workspace" ];
  };
}
