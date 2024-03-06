{ config, pkgs, lib, inputs, ... }:
let
  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) nixWallpaperFromScheme;
in
{
  imports = [
    inputs.nix-colors.homeManagerModule
  ];
  colorscheme = {
    # https://github.com/tinted-theming/schemes/blob/spec-0.11/base16/tokyo-night-dark.yaml
    slug = "tokyo-night-dark";
    name = "Tokyo Night Dark";
    author = "Michaël Ball";
    variant = "dark";
    palette = {
      base00 = "1A1B26";
      base01 = "16161E";
      base02 = "2F3549";
      base03 = "444B6A";
      base04 = "787C99";
      base05 = "A9B1D6";
      base06 = "CBCCD1";
      base07 = "D5D6DB";
      base08 = "C0CAF5";
      base09 = "A9B1D6";
      base0A = "0DB9D7";
      base0B = "9ECE6A";
      base0C = "B4F9F8";
      base0D = "2AC3DE";
      base0E = "BB9AF7";
      base0F = "F7768E";
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
