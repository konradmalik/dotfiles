{
  programs.imv.enable = true;
  xdg.desktopEntries.imv = {
    name = "Image Viewer";
    exec = "imv %F";
    icon = "imv";
    type = "Application";
    mimeType = [
      "image/png"
      "image/jpeg"
      "image/jpg"
      "image/gif"
      "image/bmp"
      "image/webp"
      "image/tiff"
      "image/x-xcf"
      "image/x-portable-pixmap"
      "image/x-xbitmap"
    ];
    terminal = false;
    categories = [
      "Graphics"
      "Viewer"
    ];
  };
}
