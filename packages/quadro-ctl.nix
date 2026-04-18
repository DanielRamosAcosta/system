{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "quadro-ctl";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "DanielRamosAcosta";
    repo = "quadro-ctl";
    rev = "v0.2.0";
    hash = "sha256-1+SetGvZ/WD3c7S6hdeUQFyO13i7znkrO5giezAYwGc=";
  };

  cargoHash = "sha256-3oaay4drDuA+pqPB+ThdYVeu185TCA4C6laH5iDSEO4=";

  meta = {
    description = "CLI tool to control Aqua Computer QUADRO fan controller via hidraw";
    homepage = "https://github.com/DanielRamosAcosta/quadro-ctl";
    license = lib.licenses.mit;
    mainProgram = "quadro-ctl";
  };
}
