{ config, pkgs, lib, ... }:
{
  imports =
    [
      ./../hardware/m3800.nix
      ./global/nixos.nix
    ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      min-free = 53374182400; # ~50GB
      max-free = 107374182400; # 100GB
    };
  };

  networking.hostName = "m3800";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  ##### disable nvidia, very nice battery life.
  hardware.nvidiaOptimus.disable = lib.mkDefault true;
  boot.blacklistedKernelModules = lib.mkDefault [ "nouveau" "nvidia" ];
  #services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  #hardware.opengl.enable = true;
  #hardware.nvidia.prime = {
  #  offload.enable = true;
  #  nvidiaBusId = "PCI:0:2:0";
  #  intelBusId = "PCI:2:0:0";
  #};

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # disable builtin gnome-keyring
  #services.gnome3.gnome-keyring.enable = lib.mkForce false;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.konrad = {
      packages = with pkgs; [
        bitwarden
        caffeine-ng
        firefox
        gnome.gnome-tweaks
        gnomeExtensions.appindicator
        slack
        spotify
        teams
        wl-clipboard
        wl-clipboard-x11
      ];
    };
  };
}
