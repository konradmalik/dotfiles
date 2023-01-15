{ config, pkgs, inputs, ... }:
let
  allHmUsers = builtins.attrNames config.home-manager.users;
  anyHyprlandEnabled = builtins.any (user: config.home-manager.users.${user}.wayland.windowManager.hyprland.enable) allHmUsers;
in
{
  imports = [
    inputs.hyprland.nixosModules.default
  ];

  programs = {
    light.enable = true;
    # enable hyprland defaults without installing the package
    # but enable only if hyprland in hm is enabled
    hyprland = {
      enable = anyHyprlandEnabled;
      package = null;
    };
  };

  # otherwise swaylock won't be able to unlock
  security.pam.services = { swaylock = { }; };

  xdg.portal = {
    enable = true;
    # hyprland has it's own fork which is automatically added via hyprland module
    wlr.enable = !anyHyprlandEnabled;
    # gtk portal needed to make gtk apps happy
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
}
