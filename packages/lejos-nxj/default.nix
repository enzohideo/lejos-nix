{
  stdenv,
  fetchurl,
  writeText,
  ant,
  jdk,
  libusb-compat-0_1,
}:
let
  udev-rule = writeText "lejos-nxj-udev-rule" ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0694", ATTRS{idProduct}=="0002", GROUP="lego", MODE="0664"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="6124", GROUP="lego", MODE="0664"
  '';
in
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
    cp -pr --reflink=auto ./{bin,lib} $out

    mkdir -p $out/lib/udev/rules.d
    cp -p --reflink=auto ${udev-rule} $out/lib/udev/rules.d/70-lego-nxj.rules

    runHook postInstall
  '';
}
