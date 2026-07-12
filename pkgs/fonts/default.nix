final: prev:

let
  mkNerdFont = prev.callPackage ./mkNerdFont.nix { };
in
{
  fonts = {
    # FIXME remove stable workaround once fixed. Unstable fails to build
    iosemka = mkNerdFont (
      prev.callPackage ./iosemka.nix {
        inherit
          ((builtins.getFlake "github:NixOS/nixpkgs/97dd352dc415e846fb278b773ff476bb38a80afb")
            .legacyPackages.${prev.pkgs.system}
          )
          iosevka
          ;
      }
    );
  };
}
