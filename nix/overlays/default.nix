final: prev: {
  yaml-utils = final.callPackage ../lib/yaml.nix { };
  darwin-zsh-completions = final.callPackage ../pkgs/darwin-zsh-completions.nix { };
}
