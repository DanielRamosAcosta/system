{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gdb
    elfutils
    binutils
    strace
    (ltrace.overrideAttrs { doCheck = false; })
    bpftrace
    (writeShellScriptBin "capture-freeze" (builtins.readFile ./capture-freeze.sh))
  ];

  environment.enableDebugInfo = true;

  boot.kernel.sysctl."kernel.yama.ptrace_scope" = 0;

  systemd.coredump = {
    enable = true;
    settings.Coredump = {
      Storage = "external";
      Compress = true;
      ProcessSizeMax = "24G";
      ExternalSizeMax = "24G";
      MaxUse = "60G";
    };
  };
}
