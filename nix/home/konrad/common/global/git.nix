{ config, pkgs, lib, customArgs, ... }:
let
  localSshSigningKey = "${config.home.homeDirectory}/.ssh/personal.pub";
  git-commit-template = pkgs.writeText "git-commit-template" ''
    # If applied, this commit will...


    # Explain why this change is being made

    # Provide links to any relevant tickets, articles or other resources

    #------------------------------------------------@---------------------*
    #
    # Remember the seven rules of a great Git commit message:
    #   - Separate subject from body with a blank line
    #   - Limit the subject line to 50 characters (@)
    #   - Capitalize the subject line
    #   - Do not end the subject line with a period
    #   - Use the imperative mood in the subject line
    #   - Wrap the body at 72 characters (*)
    #   - Use the body to explain what and why vs. how
    #
    # More info: https://chris.beams.io/posts/git-commit/
  '';
in
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
          };
        };
      }
      {
        condition = "gitdir/i:~/Code/gitlab.cerebredev.com/";
        contents = {
          user = {
            email = "konrad@cerebre.io";
            name = "Konrad Malik";
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

      commit = {
        gpgSign = true;
        template = "${git-commit-template}";
      };

      gpg = {
        format = "ssh";
        ssh =
          let
            allKeys = lib.concatStringsSep "\\n" config.sshKeys.personal.keys;
            comm = "${pkgs.coreutils}/bin/comm";
            cat = "${pkgs.coreutils}/bin/cat";
            cut = "${pkgs.coreutils}/bin/cut";
            sort = "${pkgs.coreutils}/bin/sort";
            ssh-add = "${pkgs.openssh}/bin/ssh-add";

            getSshSigningKey = pkgs.writeShellScript "getSshSigningKey" ''
              set -e
              allKeys=$(printf "${allKeys}" | ${cut} -d " " -f -2 | ${sort})
              agentKeys=$(${ssh-add} -L | ${cut} -d " " -f -2 | ${sort})
              agentFoundKey=$(${comm} -12 <(echo "$allKeys") <(echo "$agentKeys"))
              if [ -z "$agentFoundKey" ]
              then
                agentFoundKey=$(${cat} ${localSshSigningKey})
              fi
              echo "key::$agentFoundKey"
            '';
          in
          {
            allowedSignersFile = "${customArgs.dotfiles}/ssh/allowed_signers";
            defaultKeyCommand = "${getSshSigningKey}";
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

      # use defaultKeyCommand
      #user.signingKey = "${config.home.homeDirectory}/.ssh/personal.pub";

      worktree = {
        guessRemote = true;
      };
    };
  };
}
