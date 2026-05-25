final: prev:

let
  mkNerdFont = prev.callPackage ./mkNerdFont.nix { };
in
{
  fonts = {
    iosemka = mkNerdFont (prev.callPackage ./iosemka.nix { });
  };
}
