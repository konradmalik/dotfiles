{
  imports =
    [
      ./hardware-configuration.nix
      ./../common/presets/nixos.nix
      ./../common/optional/wayland-wm.nix
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
      operation = "boot";
      dates = "08:30";
    };
  };

  # enable aarch64-linux emulation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.logind.extraConfig = ''
    IdleAction=suspend
    IdleActionSec=30min
  '';
}
