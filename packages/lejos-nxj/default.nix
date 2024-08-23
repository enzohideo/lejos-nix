{ stdenv
, fetchurl
, ant
, jdk
, libusb-compat-0_1
}:

stdenv.mkDerivation rec {
  pname = "lejos-nxj";
  version = "0.9.1beta-3";

  src = fetchurl {
    url = "https://master.dl.sourceforge.net/project/nxt.lejos.p/${version}/leJOS_NXJ_${version}.tar.gz";
    hash = "sha256-8QI0tg+Yx0SbbgEC3AagHzqWr0Q1RBa1aiIGuuBNlKI=";
  };

  buildInputs = [
    ant
    jdk
    libusb-compat-0_1
  ];

  buildPhase = ''
    runHook preBuild

    cd build
    ant
    cd -

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -pr --reflink=auto ./* $out

    runHook postInstall
  '';
}
