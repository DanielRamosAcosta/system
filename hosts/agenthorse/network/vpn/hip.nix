{ writeShellScriptBin, lib, gpclient, clamav, systemd, util-linux, perl, gnugrep, coreutils }:
writeShellScriptBin "gp-hip" ''
  export PATH=${lib.makeBinPath [ gpclient clamav systemd util-linux perl gnugrep coreutils ]}:$PATH
  ${builtins.readFile ./gp-hip.sh}
''
