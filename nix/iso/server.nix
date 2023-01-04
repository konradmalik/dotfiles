{ config, pkgs, modulesPath, lib, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Enable networking
  networking.networkmanager = {
    enable = true;
    insertNameservers = [ "1.1.1.1" "1.0.0.1" ];
  };
  # we use networkmanager
  networking.wireless.enable = false;

  # Enable tailscale. We manually authenticate when we want with
  # "sudo tailscale up". If you don't use tailscale, you should comment
  # out or delete all of this.
  services.tailscale.enable = true;

  users = {
    mutableUsers = false;
    users.root = {
      hashedPassword = "$y$j9T$6jfs6Dz6yj1AaYv9lQ88O.$c18jXPnra4YVXD2ylaHbzt/DHxckrHld7mR1SH2nlo0";
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
}
