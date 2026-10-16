{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      gamescope = prev.gamescope.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (final.fetchpatch {
            name = "steamcompmgr-take-override-redirect-from-mapnotify.patch";
            url = "https://github.com/ValveSoftware/gamescope/commit/38293404f89aa20b9d9c58a97aca5ce7b1e56e30.patch";
            hash = "sha256-OP4ZsCKlmmEt58UDCCe5lZULcjc0YfdBYK8rO+aueIU=";
          })
        ];
      });
    })
  ];
}
