{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "quadro-ctl";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DanielRamosAcosta";
    repo = "quadro-ctl";
    rev = "a814f917e4181788f74a12f7278a276e5fba822f";
    hash = "sha256-OtA/Vcwe4q+bXdr5tCQJNrDulpmd7m11ooakgZMWNhU=";
  };

  cargoHash = "sha256-+D1H57AO3XKae1M5dN7C/tskA5vDo6OURnxxNoQNY6M=";

  meta = {
    description = "CLI tool to control Aqua Computer QUADRO fan controller via hidraw";
    homepage = "https://github.com/DanielRamosAcosta/quadro-ctl";
    license = lib.licenses.mit;
    mainProgram = "quadro-ctl";
  };
}
