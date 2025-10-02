{
  config,
  ...
}:
let
  inherit (config.konrad) wallpaper;
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        wallpaper
      ];
      wallpaper = [
        ",${wallpaper}"
      ];
    };
  };
}
