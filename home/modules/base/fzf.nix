{
  pkgs,
  ...
}:
{
  programs.fzf = rec {
    enable = true;
    defaultCommand = "${pkgs.fd}/bin/fd --type f";
    defaultOptions = [ "--bind 'ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all'" ];
    fileWidget = {
      command = defaultCommand;
      options = [
        "--preview '${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:200 {}'"
      ];
    };
    changeDirWidget = {
      command = "${pkgs.fd}/bin/fd --type d";
      options = [ "--preview '${pkgs.tree}/bin/tree -C {} | head -200'" ];
    };
  };
}
