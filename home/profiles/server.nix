{
  imports = [ ./nixos.nix ];

  konrad.programs.ssh-egress.allowAgentOnlyKeys = true;
}
