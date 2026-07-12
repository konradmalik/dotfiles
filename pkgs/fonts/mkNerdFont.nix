{ stdenvNoCC, nerd-font-patcher }:
font:
stdenvNoCC.mkDerivation {
  pname = "${font.pname}-nerd-font";
  version = font.version;

  src = font;

  nativeBuildInputs = [ nerd-font-patcher ];

  dontFixup = true;

  buildPhase = ''
    runHook preBuild

    find -name \*.ttf -exec nerd-font-patcher -o patched/truetype/ --no-progressbars --complete {} \;
    find -name \*.otf -exec nerd-font-patcher -o patched/opentype/ --no-progressbars --complete {} \;

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/fonts"
    cp -a patched/. "$out/share/fonts/"

    runHook postInstall
  '';
}
