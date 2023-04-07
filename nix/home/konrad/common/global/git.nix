{ pkgs, outputs, ... }:

{
  home.packages = with pkgs;
    [
      git-extras
      git-crypt
    ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      ".DS_Store"
    ];
    delta = {
      enable = true;
      options = {
        features = "side-by-side";
        # uses terminal colors according to base16 spec
        syntax-theme = "base16";
        line-numbers = true;
        navigate = true;
        hyperlinks = false;
        dark = true;
      };
    };
    userName = "Konrad Malik";
    userEmail = "konrad.malik@gmail.com";
    aliases = {
      graph = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
      unstage = "reset HEAD --";
      last = "log --name-status HEAD^..HEAD";
      conflicts = "diff --name-only --diff-filter=U";
      whatadded = "log --diff-filter=A";

      a = "add";
      ap = "add -p";
      c = "commit --verbose";
      ca = "commit -a --verbose";
      cm = "commit -m";
      cam = "commit -a -m";
      m = "commit --amend --verbose";

      f = "fetch";

      d = "diff";
      ds = "diff --stat";
      dc = "diff --cached";
      dl = "diff HEAD^..HEAD";

      p = "push";
      pl = "pull";

      s = "status -s";
      co = "checkout";
      cob = "checkout -b";

      mainbranch = "!git remote show origin | sed -n '/HEAD branch/s/.*: //p'";

      # list branches sorted by last modified
      b = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'";
      # list aliases
      la = "--list-cmds=alias";
      # gitignore.io
      gitignore = "!curl -sL https://www.toptal.com/developers/gitignore/api/$@";
    };
    extraConfig = {
      color = {
        ui = true;
      };

      core = {
        autocrlf = "input";
        fsmonitor = true;
      };

      gpg = {
        format = "ssh";
        ssh = {
          allowedSignersFile = "${outputs.lib.dotfiles}/ssh/allowed_signers";
        };
      };

      fetch = {
        prune = true;
      };

      help = {
        autocorrect = 10;
      };

      init = {
        defaultBranch = "main";
      };

      merge = {
        tool = "diffview";
      };

      "mergetool \"diffview\"" = {
        cmd = "nvim -c \"DiffviewOpen\"";
      };

      mergetool = {
        keepBackup = false;
      };

      push = {
        default = "tracking";
        autoSetupRemote = true;
      };

      pull = {
        rebase = "merges";
      };

      rebase = {
        autosquash = true;
      };

      worktree = {
        guessRemote = true;
      };
    };
  };
}
