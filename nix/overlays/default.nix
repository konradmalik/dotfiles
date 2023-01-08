final: prev: {
  yaml-utils = final.callPackage ../lib/yaml.nix { };
  darwin-zsh-completions = final.callPackage ../pkgs/darwin-zsh-completions.nix { };
  mako = final.callPackage ../pkgs/mako.nix { };
  sad = final.callPackage ../pkgs/sad.nix { };
}
