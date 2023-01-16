{ config, pkgs, lib, inputs, outputs, ... }:
let
  inherit (inputs.nix-colors) colorSchemes;
  inherit (inputs.nix-colors.lib-contrib { inherit pkgs; }) nixWallpaperFromScheme;
in
{
  imports = [
    inputs.nix-colors.homeManagerModule

    ./git.nix
    ./neovim.nix
    ./shells.nix
    ./tmux.nix
  ] ++ (builtins.attrValues (import ./../modules));

  home = {
    username = lib.mkDefault "konrad";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.11";

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
      ranger

      bat
      ripgrep
      ripgrep-all
      fd
      # fix for aarch64 is only on master as of now
      master.sad
      sd

      hyperfine
      viddy
      watchexec

      age
      dsq
      jq
      jo
      jc
      xsv

      du-dust
      duf
      procs

      bitwarden-cli
      croc
      glow
      up

      awscli
      azure-cli

      dive

      asdf-vm
      comma
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
        $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.ssh
        $DRY_RUN_CMD chmod 700 ${config.home.homeDirectory}/.ssh
        $DRY_RUN_CMD cp ${pkgs.dotfiles}/ssh/authorized_keys ${config.home.homeDirectory}/.ssh/authorized_keys
        $DRY_RUN_CMD chmod 600 ${config.home.homeDirectory}/.ssh/authorized_keys
      '';
    };
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
  xdg.configFile."ranger" = {
    source = "${pkgs.dotfiles}/ranger";
    recursive = true;
  };

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
        warn_timeout = "12h";
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

  # colorscheme = lib.mkDefault colorSchemes.catppuccin;
  colorscheme = {
    slug = "catppuccin-macchiato";
    name = "Catppuccin Macchiato";
    author = "https://github.com/catppuccin/catppuccin";
    kind = "dark";
    colors = {
      base00 = "24273A"; # base
      base01 = "1E2030"; # mantle
      base02 = "363A4F"; # surface0
      base03 = "494D64"; # surface1
      base04 = "5B6078"; # surface2
      base05 = "CAD3F5"; # text
      base06 = "F4DBD6"; # rosewater
      base07 = "B7BDF8"; # lavender
      base08 = "ED8796"; # red
      base09 = "F5A97F"; # peach
      base0A = "EED49F"; # yellow
      base0B = "A6DA95"; # green
      base0C = "8BD5CA"; # teal
      base0D = "8AADF4"; # blue
      base0E = "C6A0F6"; # mauve
      base0F = "F0C6C6"; # flamingo
    };
  };
  konrad.wallpaper =
    let
      largest = f: xs: builtins.head (builtins.sort (a: b: a > b) (map f xs));
      largestWidth = largest (x: x.width) config.konrad.monitors;
      largestHeight = largest (x: x.height) config.konrad.monitors;
    in
    lib.mkDefault (nixWallpaperFromScheme
      {
        scheme = config.colorscheme;
        width = largestWidth;
        height = largestHeight;
        logoScale = 4;
      });
}
