{ ... }:

let
  defaultCurve = {
    sensor = 1;
    curve = [
      { temp = 20; speedPercentage = 50; }
      { temp = 25; speedPercentage = 70; }
      { temp = 30; speedPercentage = 85; }
      { temp = 35; speedPercentage = 100; }
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
