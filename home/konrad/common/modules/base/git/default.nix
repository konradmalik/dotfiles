{
  config,
  pkgs,
  lib,
  customArgs,
  ...
}:
{
  home.packages = with pkgs; [
    git-extras
    git-crypt
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [ ".DS_Store" ];

    difftastic = {
      enable = true;
      display = "side-by-side";
      background = config.colorscheme.variant;
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
      clone-worktree = "!${lib.getExe' (pkgs.callPackage ./git-clone-worktree { }) "git-clone-worktree"}";

      a = "add";
      ap = "add -p";

      # list local branches sorted by last modified
      bl = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(authoremail)%(objectname:short)%09%(refname:short)' refs/heads";
      bls = "!git for-each-ref --sort='-authordate' --format='%(refname:short)' refs/heads";
      # same but remote
      br = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(authoremail)%(objectname:short)%09%(refname:short)' refs/remotes/origin";
      brs = "!git for-each-ref --sort='-authordate' --format='%(refname:short)' refs/remotes/origin";

      c = "commit --verbose";
      ca = "commit --all --verbose";
      cm = "commit -m";
      cam = "commit --all -m";
      m = "commit --amend --verbose";

      d = "diff";
      dc = "diff --cached";
      dl = "diff HEAD^..HEAD";
      ds = "diff --staged";
      dt = "diff --stat";

      g = "graph";
      l = "log";

      f = "fetch";
      p = "push";
      pf = "push --force-with-lease";
      pl = "pull";

      ri = "rebase --interactive";
      rim = "!git rebase --interactive $(git remote show origin | sed -n '/HEAD branch/s/.*: /origin/\//p')";
      rir = "!git rebase --interactive $(git rev-parse --abbrev-ref --symbolic-full-name @{u})";

      s = "status --short --branch";

      co = "checkout";
      cob = "checkout -b";

      mainbranch = "!git remote show origin | sed -n '/HEAD branch/s/.*: /origin\\//p'";
      remotebranch = "!git rev-parse --abbrev-ref --symbolic-full-name @{u}";

      # list aliases
      la = "--list-cmds=alias";
      # gitignore.io
      gitignore = "!curl -sL https://www.toptal.com/developers/gitignore/api/$@";
    };

    extraConfig = {
      branch = {
        sort = "-committerdate";
      };

      color = {
        ui = true;
      };

      column = {
        ui = "auto";
      };

      core = {
        autocrlf = "input";
        fsmonitor = true;
        untrackedcache = true;
      };

      commit = {
        gpgSign = true;
        verbose = true;
      };

      diff = {
        algotithm = "histogram";
        colormoved = "default";
        colormovedws = "allow-indentation-change";
      };

      gpg = {
        format = "ssh";
        ssh = {
          allowedSignersFile = "${customArgs.files}/allowed_signers";
        };
      };

      fetch = {
        fsckobjects = true;
        prune = true;
        pruneTags = true;
        writeCommitGraph = true;
      };

      help = {
        autocorrect = 10;
      };

      init = {
        defaultBranch = "main";
      };

      merge = {
        conflictstyle = "zdiff3";
        keepBackup = false;
        tool = "vimdiff";
      };

      mergetool = {
        prompt = false;
      };

      push = {
        default = "tracking";
        autoSetupRemote = true;
        gpgSign = "if-asked";
      };

      rebase = {
        autosquash = true;
        rebaseMerges = true;
        updateRefs = true;
      };

      receive = {
        fsckobjects = true;
      };

      rerere = {
        enabled = true;
        autoUpdate = true;
      };

      tag = {
        gpgSign = true;
      };

      transfer = {
        fsckobjects = true;
      };

      worktree = {
        guessRemote = true;
      };
    };
  };
}
