{ stdenv
, lib
, kernel
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "focal-spi";
  version = "unstable-2024-08-28";
  
  src = fetchFromGitHub {
    owner = "ftfpteams";
    repo = "ubuntu_spi";
    rev = "main";
    sha256 = "sha256-lIQJgjjJFTlLBMAKiwV2n9TjGG2Eolb3100oy/6Vf1Y=";
  };
  
  nativeBuildInputs = kernel.moduleBuildDependencies;
  
  # Fix for kernel 6.12+ header change
  patchPhase = ''
    # Replace asm/unaligned.h with linux/unaligned.h for newer kernels (6.12+)
    echo "Patching for kernel 6.12+"
    substituteInPlace focal_spi.c \
      --replace '#include <asm/unaligned.h>' '#include <linux/unaligned.h>'
  '';
  
  makeFlags = [
    "KERNEL_VERSION=${kernel.modDirVersion}"
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "CURRENT_PATH=$(PWD)"
  ];
  
  buildPhase = ''
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$(pwd) \
      modules
  '';
  
  installPhase = ''
    install -D focal_spi.ko $out/lib/modules/${kernel.modDirVersion}/misc/focal_spi.ko
  '';
  
  meta = with lib; {
    description = "Kernel module for FocalTech FTE3600 SPI fingerprint reader";
    license = licenses.unfree;  # Proprietary driver
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}