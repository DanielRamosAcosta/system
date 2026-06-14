{ ... }:

{
  services.fans = {
    enable = true;
    fans = {
      fan1 = {
        sensor = { source = "virtual"; index = 1; };
        curve = [
          { temp = 40; speedPercentage = 30; }
          { temp = 50; speedPercentage = 40; }
          { temp = 60; speedPercentage = 60; }
          { temp = 70; speedPercentage = 85; }
          { temp = 75; speedPercentage = 100; }
        ];
      };

      fan2 = {
        sensor = { source = "virtual"; index = 2; };
        curve = [
          { temp = 40; speedPercentage = 30; }
          { temp = 50; speedPercentage = 40; }
          { temp = 60; speedPercentage = 60; }
          { temp = 70; speedPercentage = 85; }
          { temp = 75; speedPercentage = 100; }
        ];
      };

      fan3 = {
        sensor = { source = "virtual"; index = 3; };
        curve = [
          { temp = 45; speedPercentage = 30; }
          { temp = 55; speedPercentage = 45; }
          { temp = 65; speedPercentage = 65; }
          { temp = 75; speedPercentage = 85; }
          { temp = 85; speedPercentage = 100; }
        ];
      };

      fan4 = {
        sensor = { source = "virtual"; index = 4; };
        curve = [
          { temp = 35; speedPercentage = 30; }
          { temp = 38; speedPercentage = 45; }
          { temp = 41; speedPercentage = 65; }
          { temp = 44; speedPercentage = 85; }
          { temp = 48; speedPercentage = 100; }
        ];
      };
    };
  };

  services.quadroSensors = {
    enable = true;
    intervalSeconds = 2;
    virtualSensors = {
      virtual1 = { kind = "hwmonByDevicePath"; devicePath = "/sys/class/nvme/nvme0"; label = "Composite"; };
      virtual2 = { kind = "hwmonByDevicePath"; devicePath = "/sys/class/nvme/nvme1"; label = "Composite"; };
      virtual3 = { kind = "hwmonName"; name = "coretemp"; label = "Package id 0"; };
      virtual4 = { kind = "hwmonMaxByName"; name = "drivetemp"; };
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
