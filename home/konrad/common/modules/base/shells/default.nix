{
  imports = [
    ./bash.nix
    ./zsh.nix
  ];

  home.shell.enableShellIntegration = true;

  programs = {
    carapace.enable = true;

    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    zoxide.enable = true;
  };
}
