{ stdenv, lib, fetchFromGitHub, kernel, kmod, ... }:

stdenv.mkDerivation rec {
  pname = "it87-custom";
  version = "4bff981a91bf9209b52e30ee24ca39df163a8bcd";

  src = fetchFromGitHub {
    owner = "frankcrawford";
    repo = "it87";
    rev = "${version}";
    sha256 = "sha256-hjNph67pUaeL4kw3cacSz/sAvWMcoN2R7puiHWmRObM=";
  };

  hardeningDisable = [ "pic" "format" ];                                             # 1
  nativeBuildInputs = kernel.moduleBuildDependencies;                       # 2

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"                                 # 3
    "KERNEL_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"  # 4
  ];

  buildPhase = ''
    runHook preBuild
    make modules KERNELRELEASE=${kernel.modDirVersion} KERNEL_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon
    cp it87.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon/it87-custom.ko
    runHook postInstall
  '';

  meta = {
    description = "A kernel module to support several chip sensors";
    homepage = "https://github.com/frankcrawford/it87";
    platforms = lib.platforms.linux;
  };
}
