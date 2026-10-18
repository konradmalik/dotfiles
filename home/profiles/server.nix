{ inputs, pkgs, ... }:
{
  imports = [ ../modules/base ];

  konrad.programs.ssh-egress.allowAgentOnlyKeys = true;

  konrad.programs.nvim.package =
    inputs.neovim.inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;
}
