{
  inputs,
  pkgs,
  ...
}:
{
  programs.neovim-pde = {
    enable = true;
    package = inputs.neovim.packages.${pkgs.system}.default;
  };
}
