{
  inputs,
  ...
}:
{
  imports = [ inputs.neovim.homeManagerModules.default ];
  programs.neovim-pde = {
    enable = true;
    cleanLspLog = true;
  };
}
