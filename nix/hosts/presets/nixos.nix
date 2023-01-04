{ config, pkgs, lib, username, ... }:
{
  imports = [
    ./programs/nix-nixos.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # lts
  boot.kernelPackages = pkgs.linuxPackages;
  # newest
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # make tmp in ram
  boot.tmpOnTmpfs = true;
  boot.tmpOnTmpfsSize = "25%";

  # bluetooth
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
    powerOnBoot = true;
    settings = {
      General = {
        FastConnectable = true;
        ReconnectAttempts = 5;
        ReconnectIntervals = "1, 2, 3";
      };
    };
  };

  # Enable networking
  networking.networkmanager = {
    enable = true;
    insertNameservers = [ "1.1.1.1" "1.0.0.1" ];
  };

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

  users = {
    mutableUsers = false;
    users.${username} = {
      shell = pkgs.zsh;
      isNormalUser = true;
      description = "${username}";
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      hashedPassword = "$y$j9T$6jfs6Dz6yj1AaYv9lQ88O.$c18jXPnra4YVXD2ylaHbzt/DHxckrHld7mR1SH2nlo0";
      # If you are using NixOps then don't use this option since it will replace the key required for deployment via ssh.
      openssh.authorizedKeys.keys =
        let
          authorizedKeysFile = builtins.readFile "${pkgs.dotfiles}/ssh/authorized_keys";
          authorizedKeysFileLines = lib.splitString "\n" authorizedKeysFile;
          onlyKeys = lib.filter (line: line != "" && !(lib.hasPrefix "#" line)) authorizedKeysFileLines;
        in
        onlyKeys;
    };
  };

  environment = {
    systemPackages = with pkgs; [
      busybox
      git
      vim
    ];
    pathsToLink = [ "/share" "/bin" ];
  };

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
