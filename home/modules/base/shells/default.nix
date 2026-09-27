{
  imports = [
    ./bash.nix
    ./zsh.nix
  ];

  home.shell.enableShellIntegration = true;

  programs = {
    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    zoxide.enable = true;
  };
}
