{
  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      style = "compact";
      sync_frequency = "15m";
      update_check = false;
      workspaces = true;
      sync = {
        records = true;
      };
    };
  };
}
