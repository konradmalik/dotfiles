final: prev:

let
  mkNerdFont = prev.callPackage ./mkNerdFont.nix { };
  # nodejs_latest (26.x) fails its own test suite on build
  # (test/parallel/test-fs-cp-async-file-modes.mjs), so pin iosevka to the
  # default LTS nodejs until that is fixed upstream.
  iosevka = prev.iosevka.override { nodejs_latest = prev.nodejs; };
in
{
  fonts = {
    iosemka = mkNerdFont (prev.callPackage ./iosemka.nix { inherit iosevka; });
    iorkeley = mkNerdFont (prev.callPackage ./iorkeley.nix { inherit iosevka; });
  };
}
