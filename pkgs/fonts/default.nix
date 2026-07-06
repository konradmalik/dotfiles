final: prev:

let
  # FIXME remove stable workaround once fixed. Unstable hangs
  mkNerdFont = prev.callPackage ./mkNerdFont.nix { inherit (final.stable.pkgs) nerd-font-patcher; };
in
{
  fonts = {
    iosemka = mkNerdFont (prev.callPackage ./iosemka.nix { });
  };
}
