{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "dotfiles";
  version = "0.0.1";
  src = ./../../files;
  installPhase = ''
    mkdir -p $out
    cp -r ./* $out/
  '';
}
