{ config, ... }:
{
  # ssh-tpm-agent only serves tpm-sealed keys, everything else it proxies to a plain
  # agent via -A, which the module wires up only if that agent is enabled here too.
  services.ssh-agent.enable = true;
  services.ssh-tpm-agent.enable = true;

  konrad.programs.ssh-egress.hardwareKeys = [ "${config.home.homeDirectory}/.ssh/hardware" ];
}
