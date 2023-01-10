{ config, pkgs, lib, username, inputs, outputs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager

    ./nix/nixos.nix
    ./home-manager.nix
  ] ++ (builtins.attrValues outputs.nixosModules);

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

  services.printing.enable = false;

  virtualisation.docker = {
    enable = true;
  };

  programs = {
    zsh.enable = true;
    ssh.startAgent = true;
  };

  sops.secrets.konrad-password = {
    sopsFile = ./../../secrets/users/konrad/secrets.yaml;
    neededForUsers = true;
  };

  users = {
    mutableUsers = false;
    users.${username} = {
      passwordFile = config.sops.secrets.konrad-password.path;
      shell = pkgs.zsh;
      isNormalUser = true;
      description = "${username}";
      extraGroups = [ "wheel" "video" "audio" ] ++ ifTheyExist [ "docker" "networkmanager" ];
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

  home-manager.users.${username} = import ./../../home/${config.networking.hostName}.nix;

  environment.systemPackages = with pkgs; [
    busybox
    git
    vim
  ];
  environment.pathsToLink = [ "/share" "/bin" ];

  # for compatibility with nix-shell, nix-build, etc.
  environment.etc.nixpkgs.source = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=/etc/nixpkgs" ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
    ports = [ 22 ];
    hostKeys = [{
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }];
  };

  # Open ports in the firewall.
  # but don't enable firewall by default
  networking.firewall = {
    allowedTCPPorts = config.services.openssh.ports;
    # for tailscale
    checkReversePath = "loose";
    # allowedUDPPorts = [ ... ];
  };

  # shared sops config
  sops = {
    # This will add secrets.yml to the nix store
    # You can avoid this by adding a string to the full path instead, i.e.
    #sops.defaultSopsFile = ./../../secrets/secrets.yaml;
    #defaultSopsFile = ./secrets/secrets.yaml
    # This will automatically import SSH keys as age keys
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    # This is the actual specification of the secrets.
    # secrets.example-key = { };
    # secrets."myservice/my_subdir/my_secret" = { };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
