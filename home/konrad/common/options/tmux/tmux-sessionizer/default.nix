{ pkgs, ... }:
let
  name = "tmux-sessionizer";
  script = (pkgs.writeScriptBin name (builtins.readFile ./tmux-sessionizer.sh)).overrideAttrs (old: {
    buildCommand = "${old.buildCommand}\n patchShebangs $out";
  });
  deps = with pkgs; [
    tmux
    fd
    fzf
    coreutils
  ];
in
pkgs.symlinkJoin {
  inherit name;
  paths = [ script ] ++ deps;
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
}
