{
  imports = [
    ./bash.nix
    ./zsh.nix
  ];

  programs = {
    carapace.enable = true;

    eza = {
      enable = true;
      git = true;
      icons = true;
    };

    zoxide.enable = true;
  };
}
