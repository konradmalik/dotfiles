# mako from main for that history feature
# can be removed after something newer than 1.7.1 is released
{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, scdoc
, systemd, pango, cairo, gdk-pixbuf
, wayland, wayland-protocols
, wrapGAppsHook }:

stdenv.mkDerivation rec {
  pname = "mako";
  version = "2022-12-30-main";

  src = fetchFromGitHub {
    owner = "emersion";
    repo = pname;
    rev = "5eca7d58bf9eb658ece1b32da586627118f00642";
    sha256 = "sha256-YRCS+6or/Z6KJ0wRfZDkvwbjAH2FwL5muQfVoFtq/lI=";
  };

  nativeBuildInputs = [ meson ninja pkg-config scdoc wayland-protocols wrapGAppsHook ];
  buildInputs = [ systemd pango cairo gdk-pixbuf wayland ];

  mesonFlags = [
    "-Dzsh-completions=true"
    "-Dsd-bus-provider=libsystemd"
  ];

  meta = with lib; {
    description = "A lightweight Wayland notification daemon";
    homepage = "https://wayland.emersion.fr/mako/";
    license = licenses.mit;
    maintainers = with maintainers; [ dywedir synthetica ];
    platforms = platforms.linux;
  };
}
