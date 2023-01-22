{ pkgs, lib, ... }:
pkgs.stdenv.mkDerivation {
  name = "dotfiles";
  meta = {
    description = "konradmalik dotfiles";
    licenses = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
  stdenv = pkgs.stdenvNoCC;
  src = ./../../files;
  preferLocalBuild = true;
  allowSubstitutes = false;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;
  installPhase = ''
    mkdir -p $out
    cp -r ./* $out/
  '';
}
