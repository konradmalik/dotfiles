{
  config,
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
    font = "${config.fontProfiles.monospace.family} ${
      toString (builtins.floor (config.fontProfiles.monospace.size * 1.5))
    }";
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
