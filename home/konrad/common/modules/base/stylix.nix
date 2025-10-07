{
  osConfig,
  lib,
  ...
}:
lib.mkIf (osConfig ? stylix.icons) {
  # https://github.com/nix-community/stylix/issues/1933
  stylix.icons = osConfig.stylix.icons;
}
