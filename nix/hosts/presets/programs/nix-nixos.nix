{ ... }:
{
  imports = [ ./nix-shared.nix ];
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 14d";
      persistent = true;
    };

    optimise = {
      automatic = true;
      dates = "daily";
    };
  };
  services.nix-daemon.enable = true;
}
