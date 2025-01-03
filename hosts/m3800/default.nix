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
    enable = false;
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

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
  };

  # FIXME some bug in either hyprland or somewhere else
  # suspends even if not idle after that time
  services.logind.extraConfig = ''
    #IdleAction=suspend
    IdleAction=ignore
    IdleActionSec=30min
  '';
}
