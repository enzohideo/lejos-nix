{
  stdenv,
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
{
  buildInputs = [
    ant
    jdk
    libusb-compat-0_1
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -pr --reflink=auto ./{bin,lib} $out

    mkdir -p $out/lib/udev/rules.d
    cp -p --reflink=auto ${udev-rule} $out/lib/udev/rules.d/70-lego-nxj.rules

    runHook postInstall
  '';
}
