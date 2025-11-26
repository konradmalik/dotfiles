final: prev:

let
  inherit (final) pkgs;

  mkNerdFont = pkgs.callPackage ./mkNerdFont.nix { };
in
{
  fonts = {
    iosemka = mkNerdFont (pkgs.callPackage ./iosemka.nix { });
  };
}
