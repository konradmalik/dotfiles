{
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        mouseEvents = false;
        nerdFontsVersion = "3";
        filterMode = "fuzzy";
      };
      update.method = "never";
    };
  };
}
