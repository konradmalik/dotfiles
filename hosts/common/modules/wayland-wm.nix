{
  config,
  pkgs,
  ...
}:
let
  allHmUsers = builtins.attrNames config.home-manager.users;
  anyHyprlandEnabled = builtins.any (
    user: config.home-manager.users.${user}.wayland.windowManager.hyprland.enable
  ) allHmUsers;
  anyGnomeKeyringEnabled = builtins.any (
    user: config.home-manager.users.${user}.services.gnome-keyring.enable
  ) allHmUsers;
in
{
  programs = {
    light.enable = true;
    hyprland.enable = anyHyprlandEnabled;
  };

  # otherwise swaylock won't be able to unlock
  security.pam.services = {
    swaylock = { };
  };

  # enables necessary pam stuff thus allowing to unlock per user keyring during login
  services.gnome.gnome-keyring.enable = anyGnomeKeyringEnabled;

  # for nightlight
  services.geoclue2.enable = true;

  # Initial login experience
  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
  };

  xdg.portal = {
    enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  hardware.graphics.enable = true;

  # Optional, hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
