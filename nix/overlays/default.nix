final: prev: {
  yaml-utils = final.callPackage ../lib/yaml.nix { };
  darwin-zsh-completions = final.callPackage ../packages/darwin-zsh-completions.nix { };
  mako = final.callPackage ../packages/mako.nix { };
}
