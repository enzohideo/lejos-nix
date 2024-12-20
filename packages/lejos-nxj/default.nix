{
  lib,
  stdenv,
  fetchurl,
  writeText,
  makeWrapper,
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
    pname = "lejos-nxj";
    version = "0.9.1beta-3";

    src = fetchurl {
      url = "https://master.dl.sourceforge.net/project/nxt.lejos.p/${version}/leJOS_NXJ_${version}.tar.gz";
      hash = "sha256-8QI0tg+Yx0SbbgEC3AagHzqWr0Q1RBa1aiIGuuBNlKI=";
    };

    buildPhase = ''
      runHook preBuild

      cd build
      ant
      cd -

      runHook postBuild
    '';

    postFixup = ''
      for file in $out/bin/* ; do
        wrapProgram $file \
          --set LEJOS_NXT_JAVA_HOME ${jdk}/lib/openjdk
      done
    '';

    nativeBuildInputs = [
      jdk
      ant
      makeWrapper
    ];

    buildInputs = [
      libusb-compat-0_1
    ];
  }
)
