{ config, lib, pkgs, username, ... }:

{
  imports = [
    ./programs/git.nix
    ./programs/neovim.nix
    ./programs/shells.nix
    ./programs/tmux.nix
  ];

  home = {
    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      PAGER = "less -FirSwX";
      MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
      GOPATH = "${config.home.homeDirectory}/.go";
      GOBIN = "${config.home.homeDirectory}/.go/bin";
    };

    sessionPath = [
      "$GOBIN"
      "$HOME/.cargo/bin"
      "$HOME/.local/bin"
    ];

    packages = with pkgs;[
      moreutils
      unzip
      wget
      curl
      tree
      tldr
      nq

      bat
      ripgrep
      ripgrep-all
      fd
      sd
      sad

      hyperfine
      viddy
      watchexec

      jq
      jo
      jc
      xsv
      dsq

      du-dust
      procs
      duf

      up
      croc
      bitwarden-cli
      glow

      azure-cli
      awscli

      dive

      asdf-vm
    ];

    file.".gdbinit".source = "${pkgs.dotfiles}/gdb/.gdbinit";
    file.".inputrc".source = "${pkgs.dotfiles}/inputrc/.inputrc";
    file.".earthly/config.yml".source = "${pkgs.dotfiles}/earthly/config.yml";
    file.".local/bin" = {
      source = "${pkgs.dotfiles}/bin";
      recursive = true;
    };
    activation = {
      authorized_keys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -n "$VERBOSE_ARG" ]; then
            echo "path to copy from '${pkgs.dotfiles}/ssh/authorized_keys'"
        fi
        $DRY_RUN_CMD cp ${pkgs.dotfiles}/ssh/authorized_keys ${config.home.homeDirectory}/.ssh/authorized_keys
        $DRY_RUN_CMD chmod 600 ${config.home.homeDirectory}/.ssh/authorized_keys
      '';
    };

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.11";
  };

  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # dotfiles
  xdg.configFile."glow/glow.yml".source = "${pkgs.dotfiles}/glow/glow.yml";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bottom = {
    enable = true;
    settings = {
      flags = {
        temperature_type = "c";
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
    stdlib = ''
      # enable asdf support
      use_asdf() {
        source_env "$(${pkgs.asdf-vm}/bin/asdf direnv envrc "$@")"
      }
    '';
    config = {
      global = {
        strict_env = true;
        warn_timeout = "2m";
      };
      whitelist = {
        prefix = [
          "${config.home.homeDirectory}/Code/github.com/konradmalik"
        ];
      };
    };
  };

  programs.exa = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "${pkgs.fd}/bin/fd --type f";
    defaultOptions = [
      "--bind 'ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all'"
      "--preview '${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:200 {}'"
    ];
  };

  programs.gpg = {
    enable = true;
    # let's stick to old standards for now
    homedir = "${config.home.homeDirectory}/.gnupg";
  };

  programs.k9s = {
    enable = true;
    skin = pkgs.yaml-utils.readYAML "${pkgs.dotfiles}/k9s/skin.yml";
  };

  programs.ssh = {
    enable = true;
    compression = true;
    controlMaster = "auto";
    controlPath = "/tmp/%r@%h:%p";
    controlPersist = "1m";
    serverAliveCountMax = 6;
    serverAliveInterval = 15;
    extraConfig = ''
      AddKeysToAgent yes
    '';

    includes = [ "config.d/*" ];
    matchBlocks = {
      git = {
        host = "github.com gitlab.com bitbucket.org";
        user = "git";
        identityFile = "${config.home.homeDirectory}/.ssh/private";
      };
      aur = {
        host = "aur.archlinux.org";
        user = "aur";
        identityFile = "${config.home.homeDirectory}/.ssh/aur";
      };
      tailscale = {
        host = "vaio xps12 rpi4-1 rpi4-2 m3800 mbp13";
        user = "${username}";
        forwardAgent = true;
        identityFile = "${config.home.homeDirectory}/.ssh/private";
      };
      vaio = lib.hm.dag.entryAfter [ "tailscale" ] {
        hostname = "100.68.248.43";
      };
      xps12 = lib.hm.dag.entryAfter [ "tailscale" ] {
        hostname = "100.120.134.20";
      };
      rpi4-1 = lib.hm.dag.entryAfter [ "tailscale" ] {
        hostname = "100.124.27.100";
      };
      rpi4-2 = lib.hm.dag.entryAfter [ "tailscale" ] {
        hostname = "100.127.1.93";
      };
      m3800 = lib.hm.dag.entryAfter [ "tailscale" ] {
        hostname = "100.108.89.62";
      };
      mbp13 = lib.hm.dag.entryAfter [ "tailscale" ] {
        hostname = "100.70.57.115";
      };
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      command_timeout = 2000;

      shell = {
        disabled = false;
        zsh_indicator = "";
        bash_indicator = "bsh ";
        format = "[$indicator]($style)";
      };

      aws.disabled = true;
      battery.disabled = true;
      cmd_duration. disabled = true;
      crystal.disabled = true;
      dart.disabled = true;
      docker_context. disabled = true;
      dotnet.disabled = true;
      elixir.disabled = true;
      elm.disabled = true;
      env_var.disabled = true;
      erlang.disabled = true;
      gcloud.disabled = true;
      golang.disabled = false;
      line_break.disabled = false;
      java.disabled = false;
      julia.disabled = true;
      kubernetes.disabled = false;
      lua.disabled = false;
      memory_usage.disabled = true;
      nim.disabled = true;
      nix_shell.disabled = false;
      package.disabled = true;
      ocaml.disabled = true;
      openstack.disabled = true;
      perl.disabled = true;
      php.disabled = true;
      purescript.disabled = true;
      python.disabled = false;
      ruby.disabled = true;
      rust.disabled = false;
      shlvl.disabled = true;
      singularity.disabled = true;
      swift.disabled = true;
      zig.disabled = true;
    };
  };

  programs.zoxide = {
    enable = true;
  };
}
