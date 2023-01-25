{ pkgs, lib, ... }:
pkgs.stdenvNoCC.mkDerivation {
  name = "dotfiles";
  meta = {
    description = "konradmalik dotfiles";
    licenses = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
  src = ./../../files;
  installPhase = ''
    mkdir -p $out
    cp -r ./* $out/
  '';
}
