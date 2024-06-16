{ self, ... }:
{
  flake = {
    checks = {
      x86_64-darwin = {
        mbp13 = self.darwinConfigurations.mbp13.system;
      };
    };
  };
}
