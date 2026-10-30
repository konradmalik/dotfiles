{
  imports = [
    ./linux-builder.nix
  ];

  home-manager.users.konrad.services.podman = {
    enable = true;
    useDefaultMachine = false;
    machines.podman-machine-default = {
      cpus = 4;
      memory = 8192;
      diskSize = 100;
      # start and stop on demand: podman machine start/stop
      autoStart = false;
    };
  };
}
