{
  imports = [ ../systems/nixos.nix ];

  programs.atuin.settings.auto_sync = false;

  konrad.programs.ssh-egress.allowAgentOnlyKeys = true;
}
