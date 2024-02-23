{
  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      auto_sync = true;
      keymap_mode = "auto";
      search_mode = "fuzzy";
      style = "compact";
      sync_frequency = "5m";
      update_check = false;
    };
  };
}
