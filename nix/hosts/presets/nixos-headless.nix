{ config, pkgs, lib, username, ... }:
{
  imports = [
    ./programs/nix/nixos.nix
  ];

  # make tmp in ram
  # boot.tmpOnTmpfs = true;
  # boot.tmpOnTmpfsSize = "25%";
  # clean tmp after reboot
  boot.cleanTmpDir = true;

  # Enable tailscale. We manually authenticate when we want with
  # "sudo tailscale up". If you don't use tailscale, you should comment
  # out or delete all of this.
  services.tailscale.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

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
  # but don't enable firewall by default
  networking.firewall = {
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