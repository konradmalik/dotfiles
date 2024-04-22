{ config, inputs, ... }:
let
  ifExistsElseNull = p: if builtins.pathExists p then p else null;
in
{
  imports = [
    inputs.neovim.homeManagerModules.default
  ];
  programs.neovim-pde = {
    enable = true;
    cleanLspLog = true;
    repositoryPath = ifExistsElseNull "${config.home.homeDirectory}/Code/github.com/konradmalik/neovim-flake";
  };
}
