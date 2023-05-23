{ config, lib, pkgs, ... }:
with lib;
let cfg = config.konrad.audio;
in
{
  options.konrad.audio = {
    enable = mkEnableOption "Enables audio thorugh configured pipewire";
  };

  config = mkIf cfg.enable {
    environment. systemPackages = with pkgs; [
      pulseaudioFull # for pactl volume control and modules like raop (used by pipewire as well)
    ];

    # Enable sound with pipewire.
    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
