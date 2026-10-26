{
  lib,
  stdenvNoCC,
  python3,
  src,
}:
# Nordwand Mono is generated from python glyph definitions; upstream only ships
# built fonts as release zips, so build it from the flake input instead.
# https://github.com/tywr/Nordwand-Mono
let
  python = python3.withPackages (
    ps: with ps; [
      fonttools
      brotli
      numpy
      skia-pathops
      booleanoperations
      ufolib2
      ttfautohint-py
      pyyaml
    ]
  );
  d = src.lastModifiedDate;
in
stdenvNoCC.mkDerivation {
  pname = "nordwand-mono";
  version = "0-unstable-${lib.substring 0 4 d}-${lib.substring 4 2 d}-${lib.substring 6 2 d}";

  inherit src;

  nativeBuildInputs = [ python ];

  buildPhase = ''
    runHook preBuild

    PYTHONPATH=src python -m generate_font

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 -t "$out/share/fonts/opentype" fonts/otf/*.otf
    install -Dm644 -t "$out/share/fonts/truetype" fonts/ttf/*.ttf

    runHook postInstall
  '';

  meta.license = lib.licenses.ofl;
}
