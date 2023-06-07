{ inputs, ... }: {
  imports = [
    inputs.neovim.homeManagerModules.default
  ];
  programs.neovim-pde = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    simpleDefaultEditor = true;
    extendGitIgnores = true;
    colorscheme = "catppuccin-macchiato";
  };
}
