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

  testInterpolateCurve_twoPoints = {
    expr = utilities.interpolateCurve [
      { temp = 20; speedPercentage = 0; }
      { temp = 50; speedPercentage = 100; }
    ];
    expected = [
      { temp = 20; speedPercentage = 0; }
      { temp = 22; speedPercentage = 6; }
      { temp = 24; speedPercentage = 13; }
      { temp = 26; speedPercentage = 20; }
      { temp = 28; speedPercentage = 26; }
      { temp = 30; speedPercentage = 33; }
      { temp = 32; speedPercentage = 40; }
      { temp = 34; speedPercentage = 46; }
      { temp = 36; speedPercentage = 53; }
      { temp = 38; speedPercentage = 60; }
      { temp = 40; speedPercentage = 66; }
      { temp = 42; speedPercentage = 73; }
      { temp = 44; speedPercentage = 80; }
      { temp = 46; speedPercentage = 86; }
      { temp = 48; speedPercentage = 93; }
      { temp = 50; speedPercentage = 100; }
    ];
  };

  testInterpolateCurve_threePoints = {
    expr = utilities.interpolateCurve [
      { temp = 25; speedPercentage = 30; }
      { temp = 35; speedPercentage = 80; }
      { temp = 40; speedPercentage = 100; }
    ];
    expected = [
      { temp = 25; speedPercentage = 30; }
      { temp = 26; speedPercentage = 35; }
      { temp = 27; speedPercentage = 40; }
      { temp = 28; speedPercentage = 45; }
      { temp = 29; speedPercentage = 50; }
      { temp = 30; speedPercentage = 55; }
      { temp = 31; speedPercentage = 60; }
      { temp = 32; speedPercentage = 65; }
      { temp = 33; speedPercentage = 70; }
      { temp = 34; speedPercentage = 75; }
      { temp = 35; speedPercentage = 80; }
      { temp = 36; speedPercentage = 84; }
      { temp = 37; speedPercentage = 88; }
      { temp = 38; speedPercentage = 92; }
      { temp = 39; speedPercentage = 96; }
      { temp = 40; speedPercentage = 100; }
    ];
  };
}
