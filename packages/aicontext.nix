{ lib, rustPlatform, makeWrapper, cmake, git, src }:

rustPlatform.buildRustPackage {
  pname = "aicontext";
  version = "3.5.0-codex-native-v3";

  inherit src;
  sourceRoot = "source/code";

  cargoLock.lockFile = "${src}/code/Cargo.lock";

  nativeBuildInputs = [ cmake makeWrapper ];

  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/aicontext --suffix PATH : ${lib.makeBinPath [ git ]}
  '';

  meta = {
    description = "AI Context Manager — manage rules, skills, prompts, and MCP configurations for AI coding assistants";
    homepage = "https://github.com/DanielRamosAcosta/clr-aicontext";
    license = lib.licenses.mit;
    mainProgram = "aicontext";
  };
}
