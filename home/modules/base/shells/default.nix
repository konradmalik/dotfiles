{
  imports = [
    ./bash.nix
    ./zsh.nix
  ];

  home.shell.enableShellIntegration = true;
}
