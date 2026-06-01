{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    libnotify
    wl-clipboard
  ];

  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  services.greetd.enable = true;

  hardware.graphics.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
