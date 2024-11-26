{
  lib,
  stdenv,
  fetchurl,
  writeText,
  ant,
  jdk,
  libusb-compat-0_1,
}:
let
  base = import ../base.nix {
    inherit stdenv;
    inherit writeText;
  };
in
stdenv.mkDerivation (
  lib.mergeAttrs base rec {
    pname = "lejos-ev3";
    version = "0.9.1-beta";

    src = fetchurl {
      url = "https://phoenixnap.dl.sourceforge.net/project/ev3.lejos.p/${version}/leJOS_EV3_${version}.tar.gz";
      hash = "sha256-N981FuyZ0NIZvbf1kQoDyMlyclXB5a2zQ1jGXoL6ZYs=";
    };
  }
)
