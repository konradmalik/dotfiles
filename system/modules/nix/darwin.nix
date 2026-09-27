{
  imports = [
    ./shared.nix
  ];
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
      interval = {
        Hour = 2;
        Minute = 0;
      };
    };
  };
}
