{
  programs.hyprlock = {
    enable = true;
    settings = {
      background = {
        blur_passes = 1;
      };

      input-field = {
        size = "600, 100";

        placeholder_text = "   Screen locked";
        fail_text = "   Wrong ";

        rounding = 4;
        fade_on_empty = false;
      };
    };
  };
}
