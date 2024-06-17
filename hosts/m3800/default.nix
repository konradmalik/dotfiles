{
  imports = [
    ./hardware-configuration.nix
    ./../common/modules/wayland-wm.nix
    ./../common/nixos.nix
  ];

  networking.hostName = "m3800";

  boot.supportedFilesystems = [ "ntfs" ];

  konrad.audio.enable = true;
  konrad.hardware.bluetooth.enable = true;
  konrad.networking.wireless = {
    enable = true;
    interfaces = [ "wlp6s0" ];
  };
  konrad.services = {
    autoupgrade = {
      enable = true;
      allowReboot = false;
      operation = "boot";
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.logind.extraConfig = ''
    IdleAction=suspend
    IdleActionSec=30min
  '';
}
