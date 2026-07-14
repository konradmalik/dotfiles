final: prev:

let
  mkNerdFont = prev.callPackage ./mkNerdFont.nix { };
  # FIXME remove stable workaround once fixed. Unstable fails to build
  iosevka =
    (builtins.getFlake "github:NixOS/nixpkgs/97dd352dc415e846fb278b773ff476bb38a80afb")
    .legacyPackages.${prev.pkgs.system}.iosevka;
in
{
  fonts = {
    iosemka = mkNerdFont (prev.callPackage ./iosemka.nix { inherit iosevka; });
    iorkeley = mkNerdFont (prev.callPackage ./iorkeley.nix { inherit iosevka; });
  };
}
