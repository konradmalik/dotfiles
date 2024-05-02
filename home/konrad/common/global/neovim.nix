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
    systemLua =
      lib.mkDefault # lua
        ''
          return {
            repository_path = "${config.home.homeDirectory}/Code/github.com/konradmalik/neovim-flake";
          }
        '';
  };
}
