{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.neovim.homeManagerModules.default ];
  programs.neovim-pde.enable = true;
}
