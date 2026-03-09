---
id: NAS-9
title: Investigate UPS FSD ACCESS-DENIED error for monuser
status: Done
assignee: []
created_date: '2026-03-09 16:55'
labels:
  - ups
  - non-critical
dependencies: []
priority: low
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
During a power event, upsmon failed to send FSD (forced shutdown) to the UPS salicru with error: `ERR ACCESS-DENIED`. The NAS shut down correctly regardless, but monuser may need primary permissions with FSD access in upsd.users config. This is a non-critical improvement to ensure the UPS powers off and restores automatically when power returns.
<!-- SECTION:DESCRIPTION:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Identified issue: monuser in upsd.users likely needs `upsmon primary` role or explicit FSD action permissions. The NAS shuts down fine without this, but fixing it would allow the UPS to fully power off and auto-restore when mains power returns.
<!-- SECTION:FINAL_SUMMARY:END -->
