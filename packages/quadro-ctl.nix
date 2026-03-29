{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "quadro-ctl";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DanielRamosAcosta";
    repo = "quadro-ctl";
    rev = "2176d73870e3d5095f136da08bca2ffa226dde46";
    hash = "sha256-ir00HwNwe5JPcHNGAC0GFXaGyuljV3XuIHV16nn20go=";
  };

  cargoHash = "sha256-+D1H57AO3XKae1M5dN7C/tskA5vDo6OURnxxNoQNY6M=";

  meta = {
    description = "CLI tool to control Aqua Computer QUADRO fan controller via hidraw";
    homepage = "https://github.com/DanielRamosAcosta/quadro-ctl";
    license = lib.licenses.mit;
    mainProgram = "quadro-ctl";
  };
}
