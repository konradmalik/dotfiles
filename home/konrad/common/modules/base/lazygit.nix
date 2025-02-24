{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        overrideGpg = true;
      };
      gui = {
        filterMode = "fuzzy";
        mouseEvents = false;
        nerdFontsVersion = "3";
        promptToReturnFromSubprocess = false;
        showNumstatInFilesView = true;
      };
      update.method = "never";
    };
  };
}
