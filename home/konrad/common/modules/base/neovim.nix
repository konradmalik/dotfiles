{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.neovim.homeManagerModules.default ];
  programs.neovim-pde = {
    enable = true;
    cleanLspLog = true;
    repositoryPath = lib.mkDefault "${config.home.homeDirectory}/Code/github.com/konradmalik/neovim-flake";
  };
}
