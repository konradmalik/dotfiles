{ pkgs, lib, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        overrideGpg = true;
        paging = {
          colorArg = "always";
          pager = "${lib.getExe pkgs.delta} --dark --paging=never";
        };
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
