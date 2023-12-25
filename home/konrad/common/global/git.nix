{ config, pkgs, customArgs, ... }:
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

    includes = [
      {
        condition = "gitdir/i:~/Code/";
        contents = {
          user = {
            email = "konrad.malik@gmail.com";
            name = "Konrad Malik";
            signingKey = "${config.home.homeDirectory}/.ssh/personal.pub";
          };
        };
      }
      {
        condition = "gitdir/i:~/Code/gitlab.cerebredev.com/";
        contents = {
          user = {
            email = "konrad@cerebre.io";
            name = "Konrad Malik";
            signingKey = "${config.home.homeDirectory}/.ssh/cerebre.pub";
          };
        };
      }
    ];

    aliases = {
      graph = "log --graph --oneline --decorate --abbrev-commit";
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

      d = "diff";
      ds = "diff --stat";
      dc = "diff --cached";
      dl = "diff HEAD^..HEAD";

      g = "graph";
      l = "log";

      f = "fetch";
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
        untrackedcache = true;
      };

      commit = {
        gpgSign = true;
      };

      gpg = {
        format = "ssh";
        ssh = {
          allowedSignersFile = "${customArgs.files}/allowed_signers";
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
        tool = "vimdiff";
        conflictstyle = "diff3";
      };

      mergetool = {
        keepBackup = false;
        prompt = false;
      };

      push = {
        default = "tracking";
        autoSetupRemote = true;
      };

      pull = {
        rebase = "merges";
      };

      push = {
        gpgSign = "if-asked";
      };

      rebase = {
        autosquash = true;
        rebaseMerges = true;
      };

      tag = {
        gpgSign = true;
      };

      worktree = {
        guessRemote = true;
      };
    };
  };
}
