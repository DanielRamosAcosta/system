{ self, pkgs, ... }:
let
  runner = self.nixosConfigurations.agenthorse.config.microvm.declaredRunner;
in
{
  microvm.vms.agenthorse = {
    flake = self;
    updateFlake = "git+file:///home/dani/infra/system";
  };

  systemd.tmpfiles.rules = [
    "L+ /var/lib/microvms/agenthorse/current - - - - ${runner}"
  ];

  systemd.services.agenthorse-dataprep = {
    description = "Pre-crear la imagen LUKS de /persist y el keyvol para agenthorse";
    requiredBy = [ "microvm@agenthorse.service" ];
    before = [ "microvm@agenthorse.service" ];
    unitConfig.ConditionPathExists = "/run/agenix/agenthorse-luks";
    path = with pkgs; [ cryptsetup e2fsprogs util-linux coreutils ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      DIR=/var/lib/microvms/agenthorse
      KEY=/run/agenix/agenthorse-luks
      mkdir -p $DIR
      if [ ! -e $DIR/agenthorse-keyvol.img ]; then
        truncate -s 1M $DIR/agenthorse-keyvol.img
      fi
      dd if=$KEY of=$DIR/agenthorse-keyvol.img conv=notrunc status=none
      if [ ! -e $DIR/agenthorse-data.img ]; then
        truncate -s 262144M $DIR/agenthorse-data.img
      fi
      if ! cryptsetup isLuks $DIR/agenthorse-data.img; then
        cryptsetup luksFormat --type luks2 --batch-mode $DIR/agenthorse-data.img $KEY
        cryptsetup open $DIR/agenthorse-data.img agenthorse-prep --key-file $KEY
        mkfs.ext4 -q /dev/mapper/agenthorse-prep
        cryptsetup close agenthorse-prep
      fi
      chown microvm:kvm $DIR/agenthorse-data.img $DIR/agenthorse-keyvol.img
      chmod 0600 $DIR/agenthorse-data.img $DIR/agenthorse-keyvol.img
    '';
  };

  systemd.services.agenthorse-inhibit-sleep = {
    description = "Inhibit host sleep while the agenthorse VM is running";
    bindsTo = [ "microvm@agenthorse.service" ];
    after = [ "microvm@agenthorse.service" ];
    wantedBy = [ "microvm@agenthorse.service" ];
    serviceConfig.ExecStart = "${pkgs.systemd}/bin/systemd-inhibit --what=sleep:idle --who=agenthorse --why='work VM running' --mode=block ${pkgs.coreutils}/bin/sleep infinity";
  };
}
