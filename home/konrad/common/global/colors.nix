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
    slug = "kanagawa-wave";
    name = "Kanagawa Wave";
    author = "rebelot";
    variant = "dark";
    palette = {
      base00 = "1F1F28";
      base01 = "2A2A37";
      base02 = "223249";
      base03 = "727169";
      base04 = "C8C093";
      base05 = "DCD7BA";
      base06 = "938AA9";
      base07 = "363646";
      base08 = "C34043";
      base09 = "FFA066";
      base0A = "DCA561";
      base0B = "98BB6C";
      base0C = "7FB4CA";
      base0D = "7E9CD8";
      base0E = "957FB8";
      base0F = "D27E99";
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
