{ config, ... }:
{
  # ssh-tpm-agent only serves tpm-sealed keys, everything else it proxies to a plain
  # agent via -A, which the module wires up only if that agent is enabled here too.
  # without it ssh-add silently drops keys instead of failing, see its Add().
  services.ssh-agent.enable = true;
  services.ssh-tpm-agent.enable = true;

  konrad.programs.ssh-egress.hardwareKeys = [ "${config.home.homeDirectory}/.ssh/hardware" ];
}
