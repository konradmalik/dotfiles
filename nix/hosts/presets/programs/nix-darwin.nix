{ ... }:
{
  imports = [ ./nix-shared.nix ];
  nix = {
    configureBuildUsers = true;
    # must be >= max-jobs
    nrBuildUsers = 16;

    gc = {
      automatic = true;
      interval = {
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 14d";
    };
  };
  services.nix-daemon.enable = true;
}
