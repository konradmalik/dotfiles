{ pkgs }:
let
  mkNerdFont = pkgs.callPackage ./mkNerdFont.nix { };
in
{
  iosemka = mkNerdFont (pkgs.callPackage ./iosemka.nix { });
}
