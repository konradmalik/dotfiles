{
  stdenvNoCC,
  callPackage,
  symlinkJoin,
  colorscheme,
  fontSize,
  fontFamily,
}:
let
  nativeConfig = stdenvNoCC.mkDerivation {
    name = "wezterm-native-config";
    src = ./native;
    dontBuild = true;
    installPhase = ''
      cp -r $src $out
    '';
  };
  # manually handle nix templates to avoid IFD
  colors-lua = callPackage ./nix/colors.nix { inherit colorscheme; };
  fonts-lua = callPackage ./nix/fonts.nix { inherit fontFamily fontSize; };
in
symlinkJoin {
  name = "wezterm-config";
  paths = [
    colors-lua
    fonts-lua
    nativeConfig
  ];
}
