{
  microvm = {
    hypervisor = "qemu";
    vcpu = 16;
    mem = 40960;

    vsock.cid = 42;

    writableStoreOverlay = "/nix/.rw-store";

    interfaces = [
      {
        type = "bridge";
        id = "vm-agenthorse";
        mac = "02:00:00:00:a6:e0";
        bridge = "br0";
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
        size = 262144;
        autoCreate = false;
      }
      {
        image = "agenthorse-nix-store.img";
        mountPoint = "/nix/.rw-store";
        size = 65536;
        fsType = "ext4";
      }
      {
        image = "agenthorse-keyvol.img";
        size = 1;
        autoCreate = false;
      }
    ];
  };
}
