{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "godeez";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "mathismqn";
    repo = "godeez";
    rev = "v${version}";
    hash = "sha256-rVjknCzH35pSbb+ddNbgDv8hFbhB7iU5CoMkW9FA1rQ=";
  };

  vendorHash = "sha256-6dI78X4w9noHok2QTRAJzp8OM/0OQkYMgO4y66i18FE=";

  meta = {
    description = "Command-line tool for downloading music from Deezer";
    homepage = "https://github.com/mathismqn/godeez";
    license = lib.licenses.mit;
    mainProgram = "godeez";
  };
}
