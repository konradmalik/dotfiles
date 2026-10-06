pkgs:

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
    file = ./ntfy-send.sh;
    deps = with pkgs; [
      curl
      inetutils
    ];
  }
  {
    file = ./realize-symlink.sh;
    deps = with pkgs; [ coreutils ];
  }
  {
    file = ./scratch.sh;
  }
  {
    file = ./sops-grep.sh;
    # bash: needs >= 4.4 for 'mapfile -d' and 'wait -n', and the shebang stays
    # '/usr/bin/env bash', which on darwin would otherwise find bash 3.2
    deps = with pkgs; [
      bash
      coreutils
      ripgrep
      sops
    ];
  }
  {
    file = ./terminal-testdrive.sh;
    # no ncurses: its share/terminfo collides with ghostty's in the home-manager path,
    # and tput is only used with an '|| echo 80' fallback anyway
    deps = with pkgs; [
      bc
      coreutils
      gawk
    ];
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
      fd
      gnused
    ];
  }
  {
    file = ./uuid.py;
    deps = with pkgs; [ python3 ];
  }
  {
    file = ./weather.sh;
    deps = with pkgs; [ curl ];
  }
]
