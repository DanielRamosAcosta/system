{
  microvm = {
    hypervisor = "qemu";
    vcpu = 16;
    mem = 40960;

    vsock.cid = 42;

    writableStoreOverlay = "/nix/.rw-store";

    interfaces = [
      {
        type = "tap";
        id = "vm-agenthorse";
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
