{ pkgs, lib, ... }:
let
  # nixpkgs builds zathura with the pdf-mupdf, ps, djvu and cb plugins.
  mimeTypes = [
    "application/pdf"
    "application/oxps"
    "application/postscript"
    "application/vnd.comicbook+zip"
    "application/vnd.comicbook-rar"
    "application/x-cb7"
    "application/x-cbr"
    "application/x-cbt"
    "application/x-cbz"
    "image/vnd.djvu"
    "image/vnd.djvu+multipage"
  ];
in
{
  home.packages = [ pkgs.zathura ];

  xdg.mimeApps.defaultApplications = lib.genAttrs mimeTypes (_: [ "org.pwmt.zathura.desktop" ]);
}
