{
  config,
  pkgs,
  lib,
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
    hyprland = {
      enable = anyHyprlandEnabled;
      package = pkgs.hyprland;
    };
  };

  # otherwise swaylock won't be able to unlock
  security.pam.services = {
    swaylock = { };
  };

  # enables necessary pam stuff thus allowing to unlock per user keyring during login
  services.gnome.gnome-keyring.enable = anyGnomeKeyringEnabled;

  # for nightlight
  services.geoclue2.enable = lib.mkDefault true;

  xdg.portal = {
    enable = true;
    # gtk portal needed to make gtk apps happy
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    # https://nixos.wiki/wiki/Accelerated_Video_Playback
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Optional, hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
