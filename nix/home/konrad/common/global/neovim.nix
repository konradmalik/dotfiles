{ inputs, config, ... }: {
  imports = [
    inputs.neovim.homeManagerModules.default
  ];
  programs.neovim-pde = {
    enable = true;
    appName = "neovim-pde-hm";
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    simpleDefaultEditor = true;
    extendGitIgnores = true;
    colorscheme = config.colorscheme.slug;
    palette = config.colorscheme.colors;
  };
}
