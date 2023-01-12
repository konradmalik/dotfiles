{ config, pkgs, lib, username, inputs, outputs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager

    ./../global/nix/nixos.nix
  ] ++ (builtins.attrValues (import ./../global))
  ++ (builtins.attrValues outputs.nixosModules);

  home-manager.users.${username} = import ./../../../home/${config.networking.hostName}.nix;

  # make tmp in ram
  # boot.tmpOnTmpfs = true;
  # boot.tmpOnTmpfsSize = "25%";
  # clean tmp after reboot
  boot.cleanTmpDir = true;

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
    sopsFile = ./../../../secrets/users/konrad/secrets.yaml;
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
    };
  };

  environment.systemPackages = with pkgs; [
    busybox
    git
    vim
  ];
  environment.pathsToLink = [ "/share" "/bin" ];

  # for compatibility with nix-shell, nix-build, etc.
  environment.etc.nixpkgs.source = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=/etc/nixpkgs" ];

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
