{ config, pkgs, lib, inputs, ... }:
let
  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) nixWallpaperFromScheme;
in
{
  imports = [
    inputs.nix-colors.homeManagerModule
  ];
  # colorscheme = lib.mkDefault colorSchemes.catppuccin;
  colorscheme = {
    slug = "catppuccin-macchiato";
    name = "Catppuccin Macchiato";
    author = "https://github.com/catppuccin/catppuccin";
    variant = "dark";
    palette = {
      base00 = "24273A"; # base
      base01 = "1E2030"; # mantle
      base02 = "363A4F"; # surface0
      base03 = "494D64"; # surface1
      base04 = "5B6078"; # surface2
      base05 = "CAD3F5"; # text
      base06 = "F4DBD6"; # rosewater
      base07 = "B7BDF8"; # lavender
      base08 = "ED8796"; # red
      base09 = "F5A97F"; # peach
      base0A = "EED49F"; # yellow
      base0B = "A6DA95"; # green
      base0C = "8BD5CA"; # teal
      base0D = "8AADF4"; # blue
      base0E = "C6A0F6"; # mauve
      base0F = "F0C6C6"; # flamingo
    };
  };

  konrad.wallpaper =
    let
      largest = f: xs: builtins.head (builtins.sort (a: b: a > b) (map f xs));
      largestWidth = largest (x: x.width) config.monitors;
      largestHeight = largest (x: x.height) config.monitors;
    in
    lib.mkDefault (nixWallpaperFromScheme
      {
        scheme = config.colorscheme;
        width = largestWidth;
        height = largestHeight;
        logoScale = 4;
      });
}
