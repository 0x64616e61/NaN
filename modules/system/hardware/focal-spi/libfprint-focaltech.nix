{ stdenv
, lib  
, fetchurl
, dpkg
, autoPatchelfHook
, glib
, nss
, pixman
, cairo
, gusb
, libgudev
}:

stdenv.mkDerivation rec {
  pname = "libfprint-focaltech";
  version = "1.94.4+tod1-spi-20250112";
  
  # Use the pre-patched deb file (copied locally to avoid illegal character issue)
  src = ./libfprint-focaltech.deb;
  
  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];
  
  buildInputs = [
    glib
    nss
    pixman
    cairo
    gusb
    libgudev
  ];
  
  unpackPhase = ''
    dpkg-deb -x $src .
  '';
  
  installPhase = ''
    # Install the library
    mkdir -p $out/lib
    cp -r usr/lib/x86_64-linux-gnu/* $out/lib/
    
    # Install udev rules if they exist
    if [ -d lib/udev ]; then
      mkdir -p $out/lib/udev/rules.d
      cp -r lib/udev/rules.d/* $out/lib/udev/rules.d/ || true
    fi
    
    # Create pkg-config file
    mkdir -p $out/lib/pkgconfig
    cat > $out/lib/pkgconfig/libfprint-2.pc << EOF
    prefix=$out
    exec_prefix=\''${prefix}
    libdir=\''${prefix}/lib
    includedir=\''${prefix}/include
    
    Name: libfprint
    Description: FocalTech-patched fingerprint library
    Version: ${version}
    Libs: -L\''${libdir} -lfprint-2
    Cflags: -I\''${includedir}
    EOF
  '';
  
  meta = with lib; {
    description = "Fingerprint library with FocalTech FTE3600 support";
    license = licenses.lgpl21Plus;
    platforms = [ "x86_64-linux" ];
  };
}