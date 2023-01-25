{ pkgs, ... }:
let
  name = "remove-old-snaps";
  script = (pkgs.writeScriptBin name (builtins.readFile ./remove-old-snaps.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  deps = [ ];
in
pkgs.symlinkJoin {
  inherit name;
  paths = [ script ] ++ deps;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
