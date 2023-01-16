{ config, pkgs, lib, ... }:
# currently broken on macos
lib.mkIf pkgs.stdenv.isLinux {
  home.packages = [ pkgs.khal ];
  xdg.configFile."khal/config".text = ''
    [calendars]
      [[personal]]
        path = ${config.xdg.dataHome}/khal/home
  '';
}
