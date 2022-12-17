{ config, lib, pkgs, dotfiles, dotfiles-private, ... }:

let
  neovim = pkgs.neovim.override {
    viAlias = true;
    vimAlias = true;
    withPython3 = true;
    withNodeJs = true;
    configure = {
      packages = with pkgs.vimPlugins; {

        dependencies = {
          start = [
            plenary-nvim
            nui-nvim
            nvim-web-devicons
          ];
        };

        treesitter = {
          start = [
            nvim-treesitter.withAllGrammars
            nvim-treesitter-context
          ];
          opt = [
            playground
          ];
        };

        completion = {
          start = [
            nvim-cmp
            cmp-buffer
            cmp-nvim-lsp
            cmp-path
            cmp-dap
            cmp_luasnip
          ];
        };

        lsp = {
          start = [
            nvim-lspconfig
            null-ls-nvim
            luasnip
            friendly-snippets
            fidget-nvim
          ];
        };

        dap = {
          start = [
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
          ];
        };

        telescope = {
          start = [
            telescope-nvim
            telescope-fzf-native-nvim
            telescope-file-browser-nvim
          ];
        };

        statusline = {
          start = [
            lualine-nvim
            nvim-navic
          ];
        };

        misc = {
          start = [
            (pkgs.vimUtils.buildVimPluginFrom2Nix {
              pname = "boole";
              version = "2022-11-15";
              src = pkgs.fetchFromGitHub {
                owner = "nat-418";
                repo = "boole.nvim";
                rev = "d059fd7da634aaaabddbb280709f92effd9f2dba";
                sha256 = "sha256-86+hAli8l7Htzx3SgFqE4aOoMKceMAf2M1fzUcl262g=";
              };
              meta.homepage = "https://github.com/nat-418/boole.nvim";
            })
            comment-nvim
            diffview-nvim
            gitsigns-nvim
            harpoon
            impatient-nvim
            (pkgs.vimUtils.buildVimPluginFrom2Nix {
              pname = "nvim-luaref";
              version = "2022-01-17";
              src = pkgs.fetchFromGitHub {
                owner = "milisims";
                repo = "nvim-luaref";
                rev = "9cd3ed50d5752ffd56d88dd9e395ddd3dc2c7127";
                sha256 = "sha256-nmsKg1Ah67fhGzevTFMlncwLX9gN0JkR7Woi0T5On34=";
              };
              meta.homepage = "https://github.com/milisims/nvim-luaref";
            })
            (pkgs.vimUtils.buildVimPluginFrom2Nix {
              pname = "luv-vimdocs";
              version = "2022-05-08";
              src = pkgs.fetchFromGitHub {
                owner = "nanotee";
                repo = "luv-vimdocs";
                rev = "4b37ef2755906e7f8b9a066b718d502684b55274";
                sha256 = "sha256-4WOmEvxH0ECuiViLx1KdCtKq7p5cvlwCW9eV7J5Pblo=";
              };
              meta.homepage = "https://github.com/nanotee/luv-vimdocs";
            })
            nvim-spectre
            which-key-nvim
          ];
          opt = [
            vim-fugitive
          ];
        };

        ui = {
          start = [
            catppuccin-nvim
            dressing-nvim
            (pkgs.vimUtils.buildVimPluginFrom2Nix {
              pname = "neo-tree-nvim";
              version = "2022-12-17";
              src = pkgs.fetchFromGitHub {
                owner = "nvim-neo-tree";
                repo = "neo-tree.nvim";
                rev = "73a90f6a736b51168ed05d89ed8872f75b98471c";
                sha256 = "sha256-/WLOKFdngvHPgeJc7xGnWx8yUjr2KSnrbOgP3nzS+jY=";
              };
              meta.homepage = "https://github.com/nvim-neo-tree/neo-tree.nvim";
            })
            # go back to this once better/more stable
            # noice-nvim
          ];
        };
      };
    };
  };
in
{
  home = {
    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      EDITOR = "nvim";
      VISUAL = "nvim";
      GIT_EDITOR = "nvim";
      DIFFPROG = "nvim -d";
      PAGER = "less -FirSwX";
      MANPAGER = "sh -c 'col -bx | ${pkgs.bat}/bin/bat -l man -p'";
    };

    sessionPath = [
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

      git-extras
      git-crypt

      bat
      ripgrep
      ripgrep-all
      fd
      sd
      sad

      neovim
      nodePackages.prettier
      shfmt
      shellcheck

      hyperfine
      viddy
      watchexec

      jq
      jo
      jc
      dsq
      tidy-viewer

      du-dust
      procs

      up
      croc
      bitwarden-cli
      glow

      azure-cli
      awscli

      dive

      asdf-vm
    ];

    file.".gdbinit".source = "${dotfiles}/gdb/.gdbinit";
    file.".inputrc".source = "${dotfiles}/inputrc/.inputrc";
    file.".earthly/config.yml".source = "${dotfiles}/earthly/config.yml";
    file.".local/bin" = {
      source = "${dotfiles}/bin";
      recursive = true;
    };
    file.".ssh/config.d".source = "${pkgs.dotfiles-private}/ssh";

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
  xdg.configFile."glow/glow.yml".source = "${dotfiles}/glow/glow.yml";
  xdg.configFile."nvim" = {
    source = "${dotfiles}/neovim";
    recursive = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };


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
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    tmux.enableShellIntegration = true;
    defaultCommand = "${pkgs.fd}/bin/fd --type f";
    defaultOptions = [
      "--bind 'ctrl-a:select-all,ctrl-d:deselect-all,ctrl-t:toggle-all'"
      "--preview '${pkgs.bat}/bin/bat --color=always --style=numbers --line-range=:200 {}'"
    ];
  };

  programs.git = {
    enable = true;
    package = pkgs.git;
    lfs.enable = true;
    delta = {
      enable = true;
      options = {
        features = "side-by-side";
        syntax-theme = "Dracula";
        line-numbers = true;
        navigate = true;
        hyperlinks = false;
        dark = true;
      };
    };
    userName = "Konrad Malik";
    userEmail = "konrad.malik@gmail.com";
    signing = {
      key = "F75F59DD45C0D9016CCC3287DE3F236F1516A431";
      signByDefault = true;
    };
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
        conflictstyle = "diff3";
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

      worktree = {
        guessRemote = true;
      };
    };
  };

  programs.gpg = {
    enable = true;
    # let's stick to old standards for now
    homedir = "${config.home.homeDirectory}/.gnupg";
  };

  programs.k9s = {
    enable = true;
    skin = pkgs.lib.readYAML "${dotfiles}/k9s/skin.yml";
  };

  programs.ssh = {
    enable = true;
    compression = true;
    controlMaster = "auto";
    controlPath = "/tmp/%r@%h:%p";
    controlPersist = "1m";
    serverAliveCountMax = 6;
    serverAliveInterval = 15;

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
        user = "konrad";
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
        hostname = "100.67.218.5";
      };
      mbp13 = lib.hm.dag.entryAfter [ "tailscale" ] {
        hostname = "100.70.57.115";
      };
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
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

  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
    # tmux-256color is the proper one to enable italics
    # just ensure you have that terminfo, newer ncurses provide it
    # Macos does not have it but we fix that by installing ncurses through nix-darwin
    # screen-256color works properly everywhere but does not have italics
    terminal = "tmux-256color";
    keyMode = "vi";
    escapeTime = 0;
    baseIndex = 1;
    historyLimit = 50000;
    extraConfig = lib.strings.concatStringsSep "\n" [
      (builtins.readFile "${dotfiles}/tmux/konrad.conf")
      (builtins.readFile "${dotfiles}/tmux/catppuccin.conf")
    ];
    plugins = [
      (pkgs.tmuxPlugins.mkTmuxPlugin
        {
          pluginName = "tmux-suspend";
          version = "main";
          src = pkgs.fetchFromGitHub
            {
              owner = "MunifTanjim";
              repo = "tmux-suspend";
              rev = "f7d59c0482d949013851722bb7de53c0158936db";
              sha256 = "sha256-+1fKkwDmr5iqro0XeL8gkjOGGB/YHBD25NG+w3iW+0g=";
            };
        })
      (pkgs.tmuxPlugins.mkTmuxPlugin
        {
          pluginName = "tmux-mode-indicator";
          version = "main";
          src = pkgs.fetchFromGitHub
            {
              owner = "MunifTanjim";
              repo = "tmux-mode-indicator";
              rev = "11520829210a34dc9c7e5be9dead152eaf3a4423";
              sha256 = "sha256-hlhBKC6UzkpUrCanJehs2FxK5SoYBoiGiioXdx6trC4=";
            };
        })
    ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
    autocd = true;
    dotDir = ".config/zsh";
    defaultKeymap = "viins";
    profileExtra = ''
      # sourced on login shell, after zshenv.
      # Once in linux, on every new terminal in macos

      if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
        export SESSION_TYPE=remote/ssh
      else
        export SESSION_TYPE=local
      fi
    '';
    shellAliases = {
      # For a full list of active aliases, run `alias`.
      # to run command that is shadowed by an alias run (for example): \ls or command ls
      # allow sudo with aliases
      sudo = "sudo ";
      # prime
      txs = "tmux-sessionizer";
      txw = "tmux-windowizer";
      # cat on steroids
      cat = "bat";
      # colorize stuff
      grep = "grep --color=auto";
      ip = "ip --color";
      # faster navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      # safety measures
      rm = "rm -i";
      mv = "mv -i";
      # modern watch
      watch = "viddy";
      # csv pretty print
      tv = "tidy-viewer";
      # git (use for example g add instead of git add)
      g = "git";
    };
    history = {
      path = "${config.xdg.dataHome}/zsh/zsh_history";
      expireDuplicatesFirst = true;
      extended = false;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
      save = 100000;
      size = 100000;
    };
    initExtraFirst = ''
      # beeping is annoying
      unsetopt beep
      # alacritty icon jumping
      # https://github.com/alacritty/alacritty/issues/2950#issuecomment-706610878
      printf "\e[?1042l"

      # enable directories stack
      setopt autopushd           # Push the current directory visited on the stack.
      setopt pushdignoredups    # Do not store duplicates in the stack.
      setopt pushdsilent         # Do not print the directory stack after pushd or popd.
    '';
    initExtra = ''
      ## Reduce latency when pressing <Esc>
      export KEYTIMEOUT=1

      # force vi mode for zle (zsh line editor)
      # (already done via viins)
      # bindkey -v

      # fix backspace issues according to https://superuser.com/questions/476532/how-can-i-make-zshs-vi-mode-behave-more-like-bashs-vi-mode/533685#533685
      bindkey "^?" backward-delete-char

      # Enable to edit command line in $EDITOR
      autoload -Uz edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd '^v' edit-command-line

      # tmux baby
      bindkey -s '^f' '^utmux-sessionizer^M'

      #### Functions
      weather() {
          local param="$1"
          if [ -z "$param" ]; then
              curl "wttr.in/?F"
          else
              curl "wttr.in/''${param}?F"
          fi
      }

      timezsh() {
          local shell=''${1-''$SHELL}
          for i in $(seq 1 10); do time $shell -i -c exit; done
      }

      # fix for tmux ssh socket
      fix_ssh_auth_sock() {
          # (On) reverses globbing order
          # https://unix.stackexchange.com/a/27400
          for tsock in /tmp/ssh*/agent*(On); do
              if [ -O "$tsock" ]; then
                  sock=$tsock
                  break
              fi
          done
          if [ -n "$sock" ]; then
              export SSH_AUTH_SOCK="$sock"
              echo "New socket: $sock"
          else
              echo "Could not find appropriate socket :("
              unset SSH_AUTH_SOCK
          fi
      }

      # update asdf and all plugins
      asdf-update() {
          # actually we manage asdf via nix...
          #asdf update
          asdf plugin-update --all
      }

      # update nix
      nix-update() {
          if [ "$(uname)" = "Darwin" ]; then
              darwin-rebuild switch --flake "git+file:///Users/konrad/Code/dotfiles#$(whoami)@$(hostname)"
          elif [ "$(uname)" = "Linux" ]; then
              # current user's home (flakes enabled)
              home-manager switch --flake "git+file:///home/konrad/Code/dotfiles#$(whoami)@$(hostname)"
              # system-wide
              sudo --login sh -c 'nix-channel --update; nix-env -iA nixpkgs.nix nixpkgs.cacert; systemctl daemon-reload; systemctl restart nix-daemon'
          fi
      }

      # clean nix
      nix-clean() {
          if [ "$(uname)" = "Darwin" ]; then
              darwin-rebuild switch --flake "git+file:///Users/konrad/Code/dotfiles#$(whoami)@$(hostname)"
          elif [ "$(uname)" = "Linux" ]; then
              # home
              home-manager expire-generations '-14 days'
          fi
          # current user's profile (flakes enabled)
          nix profile wipe-history --older-than 14d
          # nix store garbage collection
          nix store gc
          # system-wide (goes into users as well)
          sudo --login sh -c 'nix-collect-garbage --delete-older-than 14d'
      }

      # update functions
      if [ "$(uname)" = "Darwin" ]; then
          mac-upgrade() {
              brew update \
              && brew upgrade \
              && brew upgrade --cask \
              && nix-update \
              && asdf-update
          }
          mac-clean() {
              brew autoremove \
              && brew cleanup \
              && nix-clean
          }
      elif [ "$(uname)" = "Linux" ]; then
          if [ -f "/etc/arch-release" ]; then
              arch-upgrade() {
                  yay -Syu --sudoloop \
                      --removemake \
                      --devel \
                      --nocleanmenu \
                      --nodiffmenu \
                      --noeditmenu \
                      --noupgrademenu \
                  && nix-update \
                  && (flatpak update || true) \
                  && asdf-update
              }
              arch-clean() {
                  yay -Sc --noconfirm \
                  && nix-clean
              }
          elif [ -f "/etc/debian_version" ]; then
              ubuntu-upgrade() {
                  sudo apt update \
                  && sudo apt upgrade -y \
                  && sudo snap refresh \
                  && nix-update \
                  && (flatpak update || true) \
                  && asdf-update
              }
              ubuntu-clean() {
                  sudo apt autoremove -y \
                  && sudo apt clean \
                  && sudo $HOME/.local/bin/remove-old-snaps.sh \
                  && nix-clean
              }
        fi
      fi

      # TODO how to do it 'nix way'?
      # Register SSH_AUTH_SOCK only if not in SSH
      if [ -z "$SESSION_TYPE" ] || [ "$SESSION_TYPE"  = 'local' ]; then
        if ! pgrep -u "$USER" ssh-agent > /dev/null; then
            ssh-agent -t 24h > "$XDG_RUNTIME_DIR/ssh-agent.env"
        fi
        if [[ ! -e "$SSH_AUTH_SOCK" ]]; then
            source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
        fi
      fi
    '';
    completionInit = ''
      autoload -U compinit && compinit
      # autocompletion
      autoload -Uz compinit && compinit
      # bash-compatible mode
      autoload -Uz bashcompinit && bashcompinit
      # use cache
      zstyle ':completion::complete:*' use-cache 1
      # autocompletion menu
      zstyle ':completion:*' menu select
      # shift-tab to go back in completions
      bindkey '^[[Z' reverse-menu-complete
      # autocomplete with sudo
      zstyle ':completion::complete:*' gain-privileges 1
      # case insensitive and partial
      zstyle ':completion:*' matcher-list ''' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
      # Defining the Completers
      zstyle ':completion:*' completer _extensions _complete _approximate
      # display completer while waiting
      zstyle ":completion:*" show-completer true

      # we need that as long as we use asdf and want autocompletion for those tools
      # lazy load zsh completion
      completers=(
          kubectl "kubectl completion zsh"
          helm "helm completion zsh"
          k3d "k3d completion zsh"
          kind "kind completion zsh"
          flux "flux completion zsh"
          tilt "tilt completion zsh"
          poetry "poetry completions zsh"
      )
      for ((i=1; i<''${#completers[@]}; i+=2)); do
          local cmd="''${completers[i]}"
          local completer="''${completers[i+1]}"

          eval "
              function _lazycomplete_$cmd {
                  if command -v $cmd &>/dev/null; then
                      unfunction _lazycomplete_$cmd
                      # if a dedicated completions file is already handled by package manager
                      # do nothing
                      if [ ! -f $ZSH_VENDOR_COMPLETIONS/_$cmd ]; then
                          compdef -d $cmd
                          source <($completer)
                          # find the completion function we just sourced, some names are non-deterministic
                          local ccmd=\$(print -l \''${(ok)functions[(I)_*]} | grep \"$cmd\" | grep --invert-match \"^__\" | grep --invert-match \"debug\" | head -n 1)
                          # just in case, some generator commands expect to pass this manually, like tilt
                          # and some generate the command badly, like poetry. This is a mess
                          compdef \$ccmd $cmd
                          \$ccmd \"\$@\"
                      else
                          # it is already provided by package manager
                      fi
                  fi
              }
              compdef _lazycomplete_$cmd $cmd
          "
      done
    '';
  };
}
