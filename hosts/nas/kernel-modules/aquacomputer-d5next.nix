{ stdenv, lib, fetchFromGitHub, kernel, ... }:

stdenv.mkDerivation {
  pname = "aquacomputer-d5next";
  version = "9ae7fd5";

  src = fetchFromGitHub {
    owner = "aleksamagicka";
    repo = "aquacomputer_d5next-hwmon";
    rev = "9ae7fd5";
    sha256 = "sha256-2eh+hMzIz+UwJRp2Ys6/AW0l/l8C8a4DF78X2Vk73G0=";
  };

  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  buildPhase = ''
    runHook preBuild
    make modules KERNELRELEASE=${kernel.modDirVersion} KERNEL_BUILD=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon
    cp aquacomputer_d5next.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon/
    runHook postInstall
  '';

  meta = {
    description = "Out-of-tree hwmon driver for Aquacomputer devices with PWM curve support";
    homepage = "https://github.com/aleksamagicka/aquacomputer_d5next-hwmon";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
