{ pkgs, lib, ... }:
{
  home.packages =
    with pkgs;
    [
      curl
      dnsutils
      file
      inetutils
      lsof
      moreutils
      tree
      unixtools.xxd
      wget

      croc
      ouch
      zip

      fd
      fpp
      ripgrep
      ripgrep-all
      sad
      scooter

      dua
      entr
      hyperfine
      procs
      progress
      viddy

      age
      fq
      jc
      jo
      jq
      yq-go

      gh
      glab
    ]
    ++ (builtins.attrValues custom.scripts)
    ++ lib.optionals stdenvNoCC.isLinux [
      psmisc
      trace-cmd
    ]
    # FIXME build failure on aarch64-darwin
    ++ lib.optionals stdenvNoCC.isDarwin [
      (builtins.getFlake "github:NixOS/nixpkgs/89570f24e97e614aa34aa9ab1c927b6578a43775")
      .legacyPackages.${pkgs.system}.colima
    ];
}
