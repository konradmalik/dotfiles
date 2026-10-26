{ pkgs, inputs }:

let
  mkNerdFont = pkgs.callPackage ./mkNerdFont.nix { };
in
{
  iorkeley = mkNerdFont (pkgs.callPackage ./iorkeley.nix { });
  nordwand = mkNerdFont (pkgs.callPackage ./nordwand.nix { src = inputs.nordwand-mono; });
}
