#!/usr/bin/env bash
base=$(gpclient hip --client-version "6.2.1-276" --client-os Linux --cookie dummy --md5 d41d8cd98f00b204e9800998ecf8427e 2>/dev/null \
  | perl -0777 -pe 's{<os>[^<]*</os>}{<os>NixOS 26.05</os>}g; s{<os-vendor>[^<]*</os-vendor>}{<os-vendor>NixOS</os-vendor>}g')

ver=$(clamscan -V 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
[ -z "$ver" ] && ver="1.4.6"

rt=no
if systemctl is-active --quiet clamav-clamonacc 2>/dev/null; then rt=yes; fi

enc=unencrypted
if findmnt -n -o SOURCE /persist 2>/dev/null | grep -q '/dev/mapper'; then enc=encrypted; fi

AM="<entry name=\"anti-malware\"><list><entry><ProductInfo><Prod vendor=\"Cisco Systems, Inc.\" name=\"ClamAV\" version=\"$ver\" defver=\"27332\" engver=\"$ver\" datemon=\"11\" dateday=\"13\" dateyear=\"2026\" prodType=\"3\" osType=\"1\"/><real-time-protection>$rt</real-time-protection><last-full-scan-time>n/a</last-full-scan-time></ProductInfo></entry></list></entry>"
DE="<entry name=\"disk-encryption\"><list><entry><ProductInfo><Prod vendor=\"The Cryptsetup Project\" name=\"dm-crypt\" version=\"2.7.5\"/><drives><entry><drive-name>All</drive-name><enc-state>$enc</enc-state></entry></drives></ProductInfo></entry></list></entry>"
export AM DE

printf '%s' "$base" \
  | perl -0777 -pe 's{<entry name="anti-malware">.*?</entry>\s*(?=<entry name="|</categories>)}{}s' \
  | perl -0777 -pe 's{<entry name="disk-encryption">.*?</entry>\s*(?=<entry name="|</categories>)}{}s' \
  | perl -0777 -pe 's{</categories>}{$ENV{AM}$ENV{DE}</categories>}'
