{ pkgs }:
let
  wrapScript =
    {
      name,
      file,
      deps ? [ ],
    }:
    let
      script = (pkgs.writeScriptBin name (builtins.readFile file)).overrideAttrs (old: {
        buildCommand = "${old.buildCommand}\n patchShebangs $out";
      });
    in
    pkgs.symlinkJoin {
      inherit name;
      paths = [ script ] ++ deps;
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
    };

  scriptsToAttr =
    scripts:
    builtins.listToAttrs (
      map (
        input:
        let
          filename = builtins.baseNameOf input.file;
          name = builtins.head (builtins.split "\\." filename);
        in
        {
          inherit name;
          value = wrapScript (
            input
            // {
              inherit name;
            }
          );
        }
      ) scripts
    );
in
scriptsToAttr [
  {
    file = ./bb.sh;
  }
  {
    file = ./cbcopy.sh;
  }
  {
    file = ./cbpaste.sh;
  }
  {
    file = ./copypasta.sh;
  }
  {
    file = ./cpgb.sh;
  }
  {
    file = ./cpgc.sh;
  }
  {
    file = ./cptmp.sh;
  }
  {
    file = ./cpwd.sh;
  }
  {
    file = ./flakify.sh;
  }
  {
    file = ./flash-to.sh;
    deps = with pkgs; [
      zstd
      xz
      file
    ];
  }
  {
    file = ./google.sh;
  }
  {
    file = ./httpstatus.sh;
    deps = with pkgs; [ gnugrep ];
  }
  {
    file = ./iso8601.sh;
  }
  {
    file = ./jwt.sh;
    deps = with pkgs; [
      jc
      jq
    ];
  }
  {
    file = ./line.sh;
  }
  {
    file = ./mkcd.sh;
  }
  {
    file = ./notify.sh;
    deps = with pkgs; [ python3 ];
  }
  {
    file = ./realize-symlink.sh;
    deps = with pkgs; [ coreutils ];
  }
  {
    file = ./remind.sh;
  }
  {
    file = ./scratch.sh;
  }
  {
    file = ./serveit.sh;
    deps = with pkgs; [ python3 ];
  }
  {
    file = ./terminal-testdrive.sh;
    deps = with pkgs; [
      bc
      gawk
    ];
  }
  {
    file = ./timer.sh;
  }
  {
    file = ./tryna.sh;
  }
  {
    file = ./trynafail.sh;
  }
  {
    file = ./uniq-exts.sh;
    deps = with pkgs; [
      coreutils
      findutils
      perl
    ];
  }
  {
    file = ./uuid.sh;
    deps = with pkgs; [ python3 ];
  }
  {
    file = ./weather.sh;
    deps = with pkgs; [ curl ];
  }
]
