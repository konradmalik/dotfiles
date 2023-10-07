{ hostPkgs, guestPkgs }:
{ config, lib, modulesPath, inputs, customArgs, ... }:
let
  cores = 4;
  diskSize = 40 * 1024;
  memorySize = 8 * 1024;
  user = "konrad";

  key = builtins.elemAt (builtins.filter (k: k.type == "ed25519") config.services.openssh.hostKeys) 0;
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops

    ./../../../hosts/common/global/docker.nix
    ./../../../hosts/common/global/home-manager.nix
    ./../../../hosts/common/global/locale.nix
    ./../../../hosts/common/global/nix/shared.nix
    ./../../../hosts/common/global/openssh.nix

    ./../../../hosts/common/users/${user}/nixos.nix

    "${modulesPath}/virtualisation/qemu-vm.nix"
  ];

  sops = {
    defaultSopsFile = ./../secrets.yaml;
    age.sshKeyPaths = [ key.path ];
  };

  environment.pathsToLink = [ "/bin" "/lib" "/man" "/share" ];

  nixpkgs.pkgs = guestPkgs;

  documentation.enable = false;

  networking = {
    hostName = config.system.name;
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
  };

  users.users = {
    ${user} = {
      # because we need uid < 1000
      # (to mach macos uid and avoid permission problems)
      isSystemUser = true;
      isNormalUser = lib.mkForce false;
      group = "users";
      useDefaultShell = true;
      uid = 501;
    };
    root.password = "";
  };
  services.getty.autologinUser = "root";

  system = {
    name = "darwin-devnix";
    stateVersion = "23.11";
  };

  virtualisation = {
    inherit cores diskSize memorySize;

    host.pkgs = hostPkgs;
    diskImage = "./VMs/${config.system.name}.qcow2";

    graphics = false;

    forwardPorts = [
      { from = "host"; guest.port = 22; host.port = 2222; }
    ];

    sharedDirectories = {
      hostHome = {
        source = "/Users/${user}/Code";
        target = "/home/${user}/Code";
      };
    };
  };
}
