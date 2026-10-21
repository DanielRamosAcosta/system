{
  microvm = {
    hypervisor = "qemu";
    vcpu = 16;
    mem = 40960;

    vsock.cid = 42;

    writableStoreOverlay = "/nix/.rw-store";

    forwardPorts = [
      { from = "host"; host.address = "0.0.0.0"; host.port = 5922; guest.port = 22; }
      { from = "host"; host.address = "0.0.0.0"; host.port = 5900; guest.port = 5900; }
    ];

    interfaces = [
      {
        type = "user";
        id = "agenthorse";
        mac = "02:00:00:00:a6:e0";
      }
    ];

    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }
    ];

    volumes = [
      {
        image = "agenthorse-data.img";
        mountPoint = "/persist";
        size = 262144;
        fsType = "ext4";
      }
      {
        image = "agenthorse-nix-store.img";
        mountPoint = "/nix/.rw-store";
        size = 65536;
        fsType = "ext4";
      }
    ];
  };
}
