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

    sensors = {
      virtual1 = {
        type = "hwmonByDevicePath";
        devicePath = "/sys/class/nvme/nvme0";
        label = "Composite";
      };
      virtual2 = {
        type = "hwmonByDevicePath";
        devicePath = "/sys/class/nvme/nvme1";
        label = "Composite";
      };
      virtual3 = {
        type = "hwmonName";
        name = "coretemp";
        label = "Package id 0";
      };
      virtual4 = {
        type = "hwmonMaxByName";
        name = "drivetemp";
      };
    };
  };
}
