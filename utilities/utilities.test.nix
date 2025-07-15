# test.nix
{ pkgs ? import <nixpkgs> {} }:
let
  inherit (pkgs) lib;
  inherit (lib) runTests;
  utilities = import ./utilities.nix {inherit lib;};
in
runTests {
  testIsTransformsToBase64_1 = {
    expr = utilities.toBase64 "hola * esto es una prueba'123!!";
    expected = "aG9sYSAqIGVzdG8gZXMgdW5hIHBydWViYScxMjMhIQ==";
  };
}
