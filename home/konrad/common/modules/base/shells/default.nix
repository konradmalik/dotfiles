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
      icons = "auto";
    };

    zoxide.enable = true;
  };
}
