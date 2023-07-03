{ config, pkgs, lib, ... }:
let
  localSshSigningKey = "${config.home.homeDirectory}/.ssh/personal.pub";
  allowedSigners = pkgs.writeText "allowed_signers"
    ''
      # m3800
      konrad.malik@gmail.com,konrad@cerebre.io namespaces="git",valid-after="20221227",valid-before="20230108" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0lM5i9YyDbO7wZQvywEWFbr09wQnhQpobbdZBII0gV7zXM9sBIQODiqRqZt+7Qln+udMwKDofhNPWfnbR0TWrN44HKSdNSYaCcJYm9lEElkdVMw5H0kMVYDbitiGKCQg+BTERWFM57nLlrDJf/y5YBx7tDLL4ajWZXklgJVL4gYQxy6TeAutS/5wpR1ndOQZfToshfAP9HNZ2hJUDvAhyTYv2F9KY49neeL+eJ8GSKjriAZp3IsUUYxWZMdjspmmZ9XmtJIWc0pStuTGy5gTBxhNR8Kuv74EXG+bTf4maB+i7UwNatJiRS4CtKyMQbU0rdzs2ttfYwJf+3PCl/HBSB4qlHiEE/SVBZXY/3tOdfswoIDihzsVkvMDdbj2Rm0CetiYWWdeXnLrA+fgLjo9dtyuLnnQ734BZy7lk33mQTzSMIpThiznzXfveg2fowjiZ/ZoxEMR52UdTnl+rxUyIE38ChbT7ifjEF6jur5tToXfKStMiaVs1XHI/ifaGdHE= konrad@m3800
      konrad.malik@gmail.com,konrad@cerebre.io namespaces="git",valid-after="20230108" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIcUBQiF/k6vA4YyBgbw05SDWGidAOZYbsUVP4Tv4pzp konrad@m3800
      # mbp13
      konrad.malik@gmail.com,konrad@cerebre.io namespaces="git",valid-after="20221227",valid-before="20230108" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCvctuFgvgc8xdgFci03ftgADd00HHgiSDsLCvij4KZJXxk/IJ/jloRn1cRO4i16l+FKxun5iip3ePL3B9ivbuEdM1bUnhyM2C1sz85BGzOzZRT2zqzuVqkQmIJJ0y3YTZ7BohJNSwyYCHDrLNLD8TowNGUH8+5R52mbHupTSxqkdOo9jHZHh3zdxdttJwTkChLdz8UX0wgVx9JxwT4BwcMeLRYkHHEDKG9+uEYxsbNzRp4/LuS6ENKV9IVU0zAJcPVR55/cHZxDktVhQ75tddFT6wnYvNLjL6KqBsuOclTNbAfoo30w2WWZll2qFeOQun7rJStcNy1XMkl69/Xd7wUS81LfvL32qU9UzE9NBRz8HfKTKoyWwnJYtTC9kHybPVwobdyBZjs7rv8lCXV8TbFb+8aV3L6jC65FP2QQUw7CR1Nmi89NehUY+MeDOBuE6jIT1lsHznfYdpjdRY0tIAOrtQT+NxTQIuDzWq0DDScyJeGoSxRqRdUcRQSA6OMewk= konrad@mbp13
      konrad.malik@gmail.com,konrad@cerebre.io namespaces="git",valid-after="20230108" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGDg7JoFuhpys7a8Y0Tbyo1tk8w9T2oqpGjiGkGxSAsr konrad@mbp13
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
            allowedSignersFile = "${allowedSigners}";
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
