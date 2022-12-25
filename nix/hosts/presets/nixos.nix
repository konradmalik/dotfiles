{ config, pkgs, lib, ... }:
{
  imports = [
    ./programs/nix.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Be careful updating this.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # set this
  # networking.hostName = "hostname";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable tailscale. We manually authenticate when we want with
  # "sudo tailscale up". If you don't use tailscale, you should comment
  # out or delete all of this.
  services.tailscale.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable CUPS to print documents.
  services.printing.enable = false;

  virtualisation.docker = {
    enable = true;
  };

  programs = {
    zsh.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    mutableUsers = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    busybox
    git
    vim
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    ports = [ 22 ];
  };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = config.services.openssh.ports;
    # for tailscale
    checkReversePath = "loose";
    # allowedUDPPorts = [ ... ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
