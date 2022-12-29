{ pkgs, lib, ... }:
{
  # sway
  xdg.configFile."sway/config".source = "${pkgs.dotfiles}/sway/config";
  # swaylock
  xdg.configFile."swaylock/config".source = "${pkgs.dotfiles}/swaylock/config";
  # mako
  xdg.configFile."mako/config".source = "${pkgs.dotfiles}/mako/config";
  # waybar
  xdg.configFile."waybar/config".source = "${pkgs.dotfiles}/waybar/config";
  xdg.configFile."waybar/style.css".source = "${pkgs.dotfiles}/waybar/style.css";
  xdg.configFile."waybar/catppuccin-macchiato.css".source = "${pkgs.dotfiles}/waybar/catppuccin-macchiato.css";
  # wofi
  xdg.configFile."wofi/config".source = "${pkgs.dotfiles}/wofi/config";
  xdg.configFile."wofi/style.css".source = "${pkgs.dotfiles}/wofi/style.css";
  xdg.configFile."wofi/catppuccin-macchiato.css".source = "${pkgs.dotfiles}/wofi/catppuccin-macchiato.css";
  # night light
  services.wlsunset = {
    enable = true;
    # warsaw
    latitude = "52.2";
    longitude = "21.0";
  };
}
