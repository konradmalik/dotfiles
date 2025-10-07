{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    rofi-power-menu
  ];
  # NOTE: rofi-sensible-terminal reads $TERMINAL env variable
  programs.rofi = {
    enable = true;
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
    ];
    location = "center";
    modes = [
      "drun"
      "calc"
      "emoji"
    ];
  };
}
