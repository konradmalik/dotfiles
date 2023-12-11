{
  imports = builtins.attrValues (import ./../modules);

  konrad.programs.tmux.enable = true;
  konrad.programs.ssh-egress.enable = true;
}
