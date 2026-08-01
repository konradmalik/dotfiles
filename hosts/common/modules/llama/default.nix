# Tuned for the framework host (Framework Desktop, Ryzen AI Max+ 395 "Strix Halo"):
# vulkan because RADV supports its gfx1151 igpu, --ubatch-size 2048 because that
# measured fastest for prompt processing on it, and model quants chosen to fit the
# ~31GB the igpu can address. Revisit all three before importing this elsewhere.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  llama = import ./shared.nix;

  llama-cpp = pkgs.llama-cpp.override { vulkanSupport = true; };

  modelsDir = "/var/lib/llama-swap/models";

  exposedInterfaces = [
    "enp191s0"
    "wlan0"
    "tailscale0"
  ];
in
{
  boot.kernelParams =
    let
      maxGpuGB = 48;
      pageSizeKiB = 48;
    in
    [
      "amdgpu.gttsize=${toString (maxGpuGB * 1024)}"
      "ttm.pages_limit=${toString (maxGpuGB * 1024 * 1024 * 1024 / pageSizeKiB)}"
    ];

  services.llama-swap = {
    enable = true;
    listenAddress = "0.0.0.0";
    inherit (llama) port;

    settings = {
      logLevel = "info";
      healthCheckTimeout = 1200;
      globalTTL = 300;

      macros = {
        server = lib.concatStringsSep " " [
          (lib.getExe' llama-cpp "llama-server")
          "--host 127.0.0.1"
          "--port \${PORT}"
          "--n-gpu-layers 999"
          "--batch-size 4096"
          "--ubatch-size 2048"
          "--jinja"
          "--no-webui"
        ];
      };

      models = lib.mapAttrs (
        _: model:
        {
          inherit (model) name description;
          cmd = lib.concatStringsSep " " (
            [
              "\${server}"
              "-hf ${model.hf}"
              "--ctx-size ${toString model.contextSize}"
            ]
            ++ (model.extraArgs or [ ])
          );
        }
        // lib.optionalAttrs (model ? aliases) { inherit (model) aliases; }
      ) llama.models;
    };
  };

  systemd.services.llama-swap = {
    # NOTE: upstream points this at its CacheDirectory. Keep the models in state
    # instead, they are tens of GB and /var/cache is fair game for cleanup.
    environment.LLAMA_CACHE = lib.mkForce modelsDir;
    serviceConfig = {
      StateDirectory = "llama-swap/models";
      # NOTE: DynamicUser needs these to reach /dev/dri/renderD128 for Vulkan,
      # and PrivateUsers would map them to nobody
      SupplementaryGroups = [
        "render"
        "video"
      ];
      PrivateUsers = lib.mkForce false;
      # NOTE: breaks the amdgpu userspace driver's shader compilation
      MemoryDenyWriteExecute = lib.mkForce false;
    };
  };

  # expose only on specified interfaces
  networking.firewall.interfaces = lib.genAttrs exposedInterfaces (_: {
    allowedTCPPorts = [ config.services.llama-swap.port ];
  });
}
