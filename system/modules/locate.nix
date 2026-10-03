{ lib, ... }:
{
  services.locate = {
    enable = true;
    interval = "hourly";
    prunePaths = lib.mkOptionDefault [ "/mnt" ];
  };
}
