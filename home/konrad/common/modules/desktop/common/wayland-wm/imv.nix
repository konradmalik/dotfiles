{ pkgs, ... }:
{
  xdg.mimeApps.defaultApplications = {
    "image/jpeg" = [ "imv.desktop" ];
    "image/svg+xml" = [ "imv.desktop" ];
    "image/svg+xml-compressed" = [ "imv.desktop" ];
    "image/vnd.wap.wbmp" = [ "imv.desktop" ];
    "image/x-gray" = [ "imv.desktop" ];
    "image/x-icb" = [ "imv.desktop" ];
    "image/x-icns" = [ "imv.desktop" ];
    "image/x-ico" = [ "imv.desktop" ];
    "image/x-pcx" = [ "imv.desktop" ];
    "image/x-png" = [ "imv.desktop" ];
    "image/x-portable-anymap" = [ "imv.desktop" ];
    "image/x-portable-bitmap" = [ "imv.desktop" ];
    "image/x-portable-graymap" = [ "imv.desktop" ];
    "image/x-portable-pixmap" = [ "imv.desktop" ];
    "image/x-xbitmap" = [ "imv.desktop" ];
    "image/x-xpixmap" = [ "imv.desktop" ];
  };
  home = {
    packages = [ pkgs.imv ];
  };
}
