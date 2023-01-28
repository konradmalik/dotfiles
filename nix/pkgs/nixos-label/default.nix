{ pkgs, ... }:
let
  name = "nixos-label";
  script = (pkgs.writeScriptBin name (builtins.readFile ./nixos-label.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  deps = with pkgs; [ git ];
in
pkgs.symlinkJoin {
  inherit name;
  paths = [ script ] ++ deps;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
