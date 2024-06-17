{
  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      style = "compact";
      sync_frequency = "5m";
      update_check = false;
      workspaces = true;
    };
  };
}
