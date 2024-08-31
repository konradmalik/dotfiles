{ pkgs, ... }:
let
  name = "tmw";
  script = (pkgs.writeScriptBin name (builtins.readFile ./tmux-windowizer.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  deps = with pkgs; [
    tmux
    coreutils
  ];
in
pkgs.symlinkJoin {
  inherit name;
  paths = [ script ] ++ deps;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
