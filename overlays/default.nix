{ inputs }:
{
  additions = final: prev:
    (import ../pkgs { pkgs = final; })
    // {
      baywatch = inputs.baywatch.packages.${final.system}.bwatch;
    };

  modifications = final: prev: { };
}
