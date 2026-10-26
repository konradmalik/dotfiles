{ config, ... }:
{
  # zswap caches in front of disk swap; with zram there is nothing to put it in front of
  boot.zswap.enable = !config.zramSwap.enable;
  services.earlyoom.enable = true;
}
