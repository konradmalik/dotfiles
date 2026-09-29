{ pkgs, ... }:
{
  fonts.enableDefaultPackages = false;
  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf
    noto-fonts
    noto-fonts-cjk-sans
  ];

  fonts.fontconfig.subpixel.rgba = "rgb";
}
