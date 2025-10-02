{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.konrad.audio;
in
{
  options.konrad.audio = {
    enable = mkEnableOption "Enables audio thorugh configured pipewire";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      audio.enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };
}
