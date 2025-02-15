{ ... }:
{
  imports = [ ./shared.nix ];
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      interval = {
        Hour = 2;
        Minute = 0;
      };
    };
    linux-builder = {
      # sudo ssh linux-builder
      enable = false;
      ephemeral = true;
    };
  };
}
