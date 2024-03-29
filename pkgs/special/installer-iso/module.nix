{ config, pkgs, lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./../../../hosts/common/global/nix/nixos.nix
    ./../../../modules/home-manager/ssh-keys.nix
    ./../../../home/konrad/common/global/ssh-keys.nix
  ];

  nixpkgs = {
    hostPlatform = lib.mkDefault "x86_64-linux";
    # we provide external instance
    config = lib.mkForce { };
  };

  networking.hostName = "nix-installer-iso";
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;

  users.users.root.openssh.authorizedKeys.keys = config.sshKeys.personal.keys;

  environment.systemPackages = with pkgs; [
    busybox
    git
    vim
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };
}
