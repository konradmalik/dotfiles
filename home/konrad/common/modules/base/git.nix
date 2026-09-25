{
  config,
  pkgs,
  lib,
  ...
}:
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
      hyperlinks = true;
      navigate = true;
      side-by-side = true;
      syntax-theme = "base16";
    };
    enableGitIntegration = true;
  };

  programs.git =
    let
      difft = "${lib.getExe pkgs.difftastic}";
      hardwareKeys = config.konrad.programs.ssh-egress.hardwareKeys;
      # machines that keep no key files of their own have nothing to name here, so git
      # asks the forwarded agent instead and signs as the laptop the session came from
      agentOnly = config.konrad.programs.ssh-egress.allowAgentOnlyKeys;
      # git signs with exactly one key, no list, no fallback
      signingKeyFor =
        onDisk:
        if hardwareKeys == [ ] then
          "${config.home.homeDirectory}/.ssh/${onDisk}.pub"
        else
          "${lib.head hardwareKeys}.pub";
      userFor = email: onDisk: {
        user = {
          inherit email;
          name = "Konrad Malik";
        }
        // lib.optionalAttrs (!agentOnly) { signingKey = signingKeyFor onDisk; };
      };
    in
    {
      enable = true;
      lfs.enable = true;
      ignores = [ ".DS_Store" ];

      signing = {
        signByDefault = true;
        format = "ssh";
      };

      includes =
        let
          personal = userFor "konrad.malik@gmail.com" "personal";
          work = userFor "konrad@cerebre.io" "cerebre";
        in
        [
          {
            condition = "gitdir/i:~/Code/";
            contents = personal;
          }
          {
            condition = "gitdir/i:~/Code/github.com/cerebre-ai/";
            contents = work;
          }
          {
            condition = "gitdir/i:~/Code/gitlab.cerebredev.com/";
            contents = work;
          }
        ];

      settings = {
        alias = {
          conflicts = "diff --name-only --diff-filter=U";
          graph = "log --graph --oneline --decorate --abbrev-commit";
          last = "log --name-status HEAD^..HEAD";
          root = "rev-parse --show-toplevel";
          stats = "!git log --numstat | awk '/^[0-9-]+/{ print $NF}' | sort | uniq -c | sort -nr | head";
          stats-recent = "!git log --since 6.months.ago --numstat | awk '/^[0-9-]+/{ print $NF}' | sort | uniq -c | sort -nr | head";
          unstage = "reset HEAD --";
          whatadded = "log --diff-filter=A";

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

          dft = "difftool";
          dfts = "difftool --staged";
          dlog = "-c diff.external=${difft} log -p --ext-diff";
          dshow = "-c diff.external=${difft} show HEAD --ext-diff";

          g = "graph";
          l = "log";

          f = "fetch";
          p = "push";
          pf = "push --force-with-lease";
          pl = "pull";

          r = "rebase";
          rc = "rebase --continue";
          ri = "rebase --interactive";
          rim = "!git rebase --interactive $(git remote show origin | sed -n '/HEAD branch/s/.*: /origin\\//p')";
          rir = "!git rebase --interactive $(git rev-parse --abbrev-ref --symbolic-full-name @{u})";

          s = "status --short --branch";

          x = "reset";
          xh = "reset --hard";
          xhu = "reset --hard @{upstream}";

          co = "switch";
          cob = "switch -c";

          mainbranch = "!git remote show origin | sed -n '/HEAD branch/s/.*: /origin\\//p'";
          remotebranch = "!git rev-parse --abbrev-ref --symbolic-full-name @{u}";

          # list aliases
          la = "--list-cmds=alias";
        };

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
          verbose = true;
        };

        diff = {
          algorithm = "histogram";
          mnemonicPrefix = true;
          renames = true;
          tool = "difftastic";
        };

        difftool = {
          prompt = false;
          difftastic = {
            cmd = "${difft} \"$LOCAL\" \"$REMOTE\"";
          };
        };

        gpg = {
          # no allowedSignersFile: it could only ever hold my own keys, so it verifies
          # nothing that is not already mine
          ssh = lib.optionalAttrs agentOnly {
            # no user.signingKey to point at, so take the agent's first key. ssh-tpm-agent
            # lists its own sealed keys before the ones it proxies
            defaultKeyCommand = "ssh-add -L";
          };
        };

        fetch = {
          all = true;
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
          tool = "nvimdiff";
        };

        mergetool = {
          keepBackup = false;
          prompt = false;
        };

        pager = {
          difftool = true;
        };

        push = {
          default = "upstream";
          autoSetupRemote = true;
          followTags = true;
          gpgSign = "if-asked";
        };

        rebase = {
          autoStash = true;
          autoSquash = true;
          rebaseMerges = true;
          updateRefs = true;
        };

        rerere = {
          enabled = true;
          autoUpdate = true;
        };

        tag = {
          sort = "version:refname";
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
