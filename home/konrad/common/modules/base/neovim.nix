{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [ inputs.neovim.homeManagerModules.default ];
  programs.neovim-pde = {
    enable = true;
    cleanLspLog = true;
  };

  home.sessionVariables = {
    MANPAGER = "${lib.getExe pkgs.neovim} --clean +Man!";
  };
}
