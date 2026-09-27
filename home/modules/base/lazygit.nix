{ pkgs, lib, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        overrideGpg = true;
        diffRenderers = [
          {
            colorArg = "always";
            command = "${lib.getExe pkgs.delta} --dark --paging=never";
          }
        ];
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
