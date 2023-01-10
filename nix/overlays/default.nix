{
  additions = final: prev: import ../pkgs { pkgs = final; };

  modifications = final: prev: {
    mako = prev.mako.overrideAttrs (oldAttrs: {
      version = "2022-12-30-main";

      src = prev.fetchFromGitHub {
        owner = "emersion";
        repo = oldAttrs.pname;
        rev = "5eca7d58bf9eb658ece1b32da586627118f00642";
        sha256 = "sha256-YRCS+6or/Z6KJ0wRfZDkvwbjAH2FwL5muQfVoFtq/lI=";
      };
    });

    # workaround for rpi4 kernel:
    # https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
    makeModulesClosure = x:
      prev.makeModulesClosure (x // { allowMissing = true; });
  };
}
