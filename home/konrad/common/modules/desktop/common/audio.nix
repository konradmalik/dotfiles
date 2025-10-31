{
  services = {
    # use bluetooth devices to control media players
    mpris-proxy.enable = true;
    # daemon let's playerctl control multiple players properly
    playerctld.enable = true;
  };
}
