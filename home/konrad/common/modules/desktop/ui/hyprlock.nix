{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        no_fade_in = false;
      };

      input-field = {
        size = "600, 100";
        position = "0, 0";
        halign = "center";
        valign = "center";

        outline_thickness = 4;

        font_size = 32;

        placeholder_text = "   Screen locked";
        fail_text = "   Wrong ";

        rounding = 0;
        shadow_passes = 0;
        fade_on_empty = false;
      };

      label = {
        text = "\$FPRINTPROMPT";
        text_align = "center";
        position = "0, -100";
        halign = "center";
        valign = "center";
      };
    };
  };
}
