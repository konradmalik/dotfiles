{ config, pkgs, inputs, ... }:
{
  imports = [
    inputs.hyprland.nixosModules.default
  ];

  programs = {
    light.enable = true;
    # enable hyprland defaults without installing the package
    # TODO enable only if hyprland in hm is enabled
    hyprland = {
      enable = true;
      package = null;
    };
  };

  # otherwise swaylock won't be able to unlock
  security.pam.services = { swaylock = { }; };

  xdg.portal = {
    enable = true;
    # usually we would like to enable this for wayland, but hyprland
    # has it's own fork which is automatically added via hyprland module
    # wlr.enable = true;
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
