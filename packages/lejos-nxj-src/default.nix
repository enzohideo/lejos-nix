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
    pname = "lejos-nxj-src";
    version = "0.9.1beta-3";

    src = fetchurl {
      url = "https://master.dl.sourceforge.net/project/nxt.lejos.p/${version}/leJOS_NXJ_${version}_source.tar.gz";
      hash = "sha256-Q8glCohkqUQPqaHCqgEd5KBf2f6T/naCfiwA2DpH0dQ=";
    };

    patches = [
      ./patches/fix-build-vars.patch
      ./patches/cleanup.patch
    ];

    buildPhase = ''
      runHook preBuild

      cd release
      ant
      cd build/bin_unix/build
      ant
      cd ../

      runHook postBuild
    '';

    buildInputs = [
      ant
      jdk
      libusb-compat-0_1
    ];
  }
)
