{ pkgs, lib, ... }:
pkgs.stdenvNoCC.mkDerivation {
  name = "dotfiles";
  meta = {
    description = "konradmalik dotfiles";
    licenses = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
  src = ./../../files;
  dontUnpack = false;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out
    cp -r ./* $out/
  '';
  dontFixup = true;
}
