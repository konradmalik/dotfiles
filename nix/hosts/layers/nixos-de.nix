{ pkgs, ... }:
{
  services.xserver = {
    enable = true;
    # Configure keymap in X11
    layout = "us";
    xkbVariant = "";
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
  };

  # disable builtin gnome-keyring
  #services.gnome3.gnome-keyring.enable = lib.mkForce false;
  # instead we disable it in home-manager

  users.users.konrad.packages = with pkgs; [
    caffeine-ng
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
  ];
}
