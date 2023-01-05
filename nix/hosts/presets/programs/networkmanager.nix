{ ... }:
{
  # Enable networking
  networking.networkmanager = {
    enable = true;
    insertNameservers = [ "1.1.1.1" "1.0.0.1" ];
  };
  networking.wireless.enable = false;
}
