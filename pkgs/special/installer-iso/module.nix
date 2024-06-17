{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ./../../../hosts/common/modules/nix/nixos.nix
    ./../../../home/konrad/common/options/ssh-keys.nix
    ./../../../home/konrad/common/modules/base/ssh-keys.nix
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
