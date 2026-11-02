{
  config,
  pkgs,
  lib,
  ...
}:
let
  difft = "${lib.getExe pkgs.difftastic}";
in
{
  home.packages = with pkgs; [
    difftastic
    git-absorb
    git-extras
    git-who
  ];

  programs.delta = {
    enable = true;
    options = {
      # follow stylix instead of querying the terminal (slow/noisy in tmux, ssh);
      # with polarity "either" both are false and delta detects it
      dark = config.stylix.polarity == "dark";
      light = config.stylix.polarity == "light";
      hyperlinks = true;
      navigate = true;
      side-by-side = true;
      syntax-theme = "base16";
    };
    enableGitIntegration = true;
  };

  programs.git.settings = {
    alias = {
      dft = "difftool";
      dfts = "difftool --staged";
      dlog = "-c diff.external=${difft} log -p --ext-diff";
      dshow = "-c diff.external=${difft} show --ext-diff";
    };

    diff.tool = "difftastic";

    difftool = {
      prompt = false;
      difftastic = {
        cmd = "${difft} \"$LOCAL\" \"$REMOTE\"";
      };
    };

    pager.difftool = true;
  };
}
