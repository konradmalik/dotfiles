{ lib, ... }:
let
  # formats the nixpkgs imv build has a backend for: libjpeg, libjxl, libpng,
  # libtiff, librsvg, libheif, libnsgif, libnsbmp, libwebp
  mimeTypes = [
    "image/avif"
    "image/bmp"
    "image/gif"
    "image/heic"
    "image/heif"
    "image/jpeg"
    "image/jxl"
    "image/png"
    "image/svg+xml"
    "image/tiff"
    "image/webp"
  ];
in
{
  programs.imv = {
    enable = true;
    settings = {
      options.overlay = true;
      binds = {
        "<Ctrl+r>" = "rotate by 90";
        "<Ctrl+Shift+R>" = "rotate by -90";
      };
    };
  };

  # imv ships its own entry, but with NoDisplay=true
  xdg.desktopEntries.imv = {
    name = "Image Viewer";
    exec = "imv-dir %F";
    # imv ships no icon of its own
    icon = "image-x-generic";
    type = "Application";
    mimeType = mimeTypes;
    terminal = false;
    categories = [
      "Graphics"
      "Viewer"
    ];
  };

  xdg.mimeApps.defaultApplications = lib.genAttrs mimeTypes (_: [ "imv.desktop" ]);
}
