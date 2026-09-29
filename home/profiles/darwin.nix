{
  config,
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  # apple's middleware, the only way to reach secure enclave backed keys
  skProvider = "/usr/lib/ssh-keychain.dylib";
  inherit (config.lib.file) mkOutOfStoreSymlink;
  obsidianPath = "${config.home.homeDirectory}/Library/Mobile Documents/iCloud~md~obsidian/Documents";
in
{
  imports = [
    ../modules/base
    ../modules/desktop/alacritty.nix
    ../modules/desktop/ghostty.nix
    ../modules/desktop/mpv.nix
  ];

  home = {
    homeDirectory = "/Users/${config.home.username}";

    packages = with pkgs; [
      # make linux people at home
      coreutils
      # make sure we use gnu versions of common commands
      findutils
      gawk
      gnugrep
      gnused
    ];

    sessionVariables = {
      XDG_RUNTIME_DIR = "$TMPDIR";
      # ssh-add and ssh-keygen don't read ssh_config, they need this instead
      SSH_SK_PROVIDER = skProvider;
    };
  };

  programs.ssh.settings."*".SecurityKeyProvider = skProvider;

  konrad.programs.bitwarden.enable = true;

  konrad.programs.ssh-egress.hardwareKeys = [ "${config.home.homeDirectory}/.ssh/hardware" ];

  konrad.programs.nvim = {
    notesPath = mkOutOfStoreSymlink "${obsidianPath}/Personal";
    spellPath = mkOutOfStoreSymlink "${config.home.homeDirectory}/Code/github.com/konradmalik/neovim-flake/state/spell";
  };

  konrad.programs.restic = {
    enable = true;
    repositories.b2.includes = [
      "${config.home.homeDirectory}/Code/scratch"
      "${config.home.homeDirectory}/Desktop"
      "${config.home.homeDirectory}/Documents"
      obsidianPath
    ];
  };

  programs.zsh = {
    shellAliases = {
      tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
    };
    initContent = lib.optionalString osConfig.homebrew.enable ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
  };
}
