{
  wayland.windowManager.hyprland.settings = {
    config = {
      input = {
        kb_layout = "us,pl";
        # left-to-right:
        # use both shifts together to toggle keyboard layout
        # capslock acts as another ctrl
        # left alt allows to write special characters just like right alt
        kb_options = "grp:shifts_toggle,ctrl:nocaps";

        natural_scroll = true;

        touchpad = {
          disable_while_typing = true;
          natural_scroll = true;
          tap_to_click = true;
        };
      };

      cursor.inactive_timeout = 5;
    };

    gesture = {
      _args = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
      ];
    };
  };
}
