{ pkgs, ... }:
let
  name = "rfv";
  script = (pkgs.writeScriptBin name (builtins.readFile ./rfv.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  deps = with pkgs; [ ripgrep bat fzf ];
in
pkgs.symlinkJoin {
  inherit name;
  paths = [ script ] ++ deps;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
