{ config, pkgs, lib, ... }:
let
  allHmUsers = builtins.attrNames config.home-manager.users;
  anyHyprlandEnabled = builtins.any (user: config.home-manager.users.${user}.wayland.windowManager.hyprland.enable) allHmUsers;
  anyGnomeKeyringEnabled = builtins.any (user: config.home-manager.users.${user}.services.gnome-keyring.enable) allHmUsers;
in
{
  programs = {
    light.enable = true;
    # enable hyprland defaults without installing the package
    # but enable only if hyprland in hm is enabled
    hyprland = {
      enable = anyHyprlandEnabled;
    };
  };

  # otherwise swaylock won't be able to unlock
  security.pam.services = { swaylock = { }; };

  # enables necessary pam stuff thus allowing to unlock per user keyring during login
  services.gnome.gnome-keyring.enable = anyGnomeKeyringEnabled;

  # for nightlight
  services.geoclue2.enable = lib.mkDefault true;

  xdg.portal = {
    enable = true;
    # hyprland has it's own fork which we add explicitly via extraPortals
    wlr.enable = !anyHyprlandEnabled;
    # gtk portal needed to make gtk apps happy
    extraPortals = [
      pkgs.unstable.xdg-desktop-portal-gtk
    ];
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
}
