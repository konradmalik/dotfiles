{ lib, ... }:
let inherit (lib) types mkOption;
in
{
  options.konrad.wallpaper = mkOption {
    type = types.path;
    default = "";
    description = ''
      Wallpaper path
    '';
  };
}
