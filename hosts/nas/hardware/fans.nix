{ ... }:

let
  defaultCurve = {
    sensor = 1;
    curve = [
      { temp = 20; speedPercentage = 25; }
      { temp = 28; speedPercentage = 40; }
      { temp = 33; speedPercentage = 60; }
      { temp = 38; speedPercentage = 80; }
      { temp = 45; speedPercentage = 100; }
    ];
  };
in
{
  services.fans = {
    enable = true;
    fans = {
      fan1 = defaultCurve;
      fan2 = defaultCurve;
      fan3 = defaultCurve;
      fan4 = defaultCurve;
    };
  };
}
