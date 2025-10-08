{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.rofi = {
    enable = true;
    plugins = with pkgs; [
      rofi-emoji
    ];
    terminal = config.home.sessionVariables.TERMINAL;
    location = "center";
    modes = [
      "combi"
      "drun"
      "emoji"
      "power-menu:${lib.getExe pkgs.rofi-power-menu}"
    ];
    extraConfig = {
      combi-modi = "window,emoji,power-menu";
      cycle = true;
      hide-scrollbar = true;
      show-icons = true;
      sidebar-mode = true;
      sort = true;
    };
  };
}
