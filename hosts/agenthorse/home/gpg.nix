{ pkgs, lib, ... }:
{
  programs.gpg.enable = true;

  home.activation.importSigningKey = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -r /run/agenix/gpg-signing-key ]; then
      run ${pkgs.gnupg}/bin/gpg --batch --import /run/agenix/gpg-signing-key 2>/dev/null || true
      echo "B08111DB1928EC237546B9B938B726EB6B2B5DF7:6:" | run ${pkgs.gnupg}/bin/gpg --batch --import-ownertrust 2>/dev/null || true
    fi
    if [ -r /run/agenix/work-gpg-signing-key ]; then
      run ${pkgs.gnupg}/bin/gpg --batch --import /run/agenix/work-gpg-signing-key 2>/dev/null || true
      echo "C82D471510EC6C12B0ED28A693C50C436F0B63B2:6:" | run ${pkgs.gnupg}/bin/gpg --batch --import-ownertrust 2>/dev/null || true
    fi
  '';
}
