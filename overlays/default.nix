{ inputs }:
{
  additions = final: prev:
    (import ../pkgs { pkgs = final; })
    // {
      baywatch = inputs.baywatch.packages.${final.system}.bwatch;
    };

  modifications = final: prev: {
    # workaround for rpi4 kernel:
    # https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
    makeModulesClosure = x:
      prev.makeModulesClosure (x // { allowMissing = true; });
  };
}
