{ pkgs, lib, ... }:
{
  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        overrideGpg = true;
        # cycle with `|`
        diffRenderers = [
          {
            colorArg = "always";
            command = "${lib.getExe pkgs.delta} --paging=never";
          }
          {
            type = "extDiff";
            command = "${lib.getExe pkgs.difftastic} --color=always --background={{colorScheme}} --context={{diffContext}}";
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
