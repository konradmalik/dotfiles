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
in
{
  environment.systemPackages = with pkgs; [
    hyprshot
    impala
    libnotify
    nemo
    pamixer
    playerctl
    pavucontrol
    wl-clipboard
  ];

  programs = {
    localsend.enable = true;
    hyprland.enable = anyHyprlandEnabled;
  };

  # gtk portal needed to make gtk apps happy
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # for nightlight
  services.geoclue2.enable = true;

  # Initial login experience
  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
  };

  hardware.graphics.enable = true;

  # hint electron apps to use wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
