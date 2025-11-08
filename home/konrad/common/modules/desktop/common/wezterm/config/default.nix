{
  config,
  callPackage,
  symlinkJoin,
}:
let
  # manually handle nix templates to avoid IFD
  stylix-lua = callPackage ./nix/stylix.nix { inherit (config) stylix; };
in
symlinkJoin {
  name = "wezterm-config";
  paths = [
    stylix-lua
    ./native
  ];
}
