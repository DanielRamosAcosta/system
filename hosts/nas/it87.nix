{ stdenv, lib, fetchFromGitHub, kernel, kmod, ... }:

stdenv.mkDerivation rec {
  pname = "it87";
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
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"    # 4
    "INSTALL_MOD_PATH=$(out)"                                               # 5
  ];

  meta = {
    description = "A kernel module to support several chip sensors";
    homepage = "https://github.com/frankcrawford/it87";
    platforms = lib.platforms.linux;
  };
}
