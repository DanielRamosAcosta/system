# UPS Configuration Documentation

This document explains the UPS (Uninterruptible Power Supply) configuration for the NAS server.

## Hardware

- **Model**: Salicru UPS
- **Connection**: USB (Cypress Semiconductor USB to Serial converter)
- **USB IDs**:
  - Vendor ID: `0665`
  - Product ID: `5161`
- **Protocol**: Voltronic-QS 0.09
- **Firmware**: PM-H

## Software Stack

### NUT (Network UPS Tools)

The UPS is managed by NUT version 2.8.2 with the following components:

1. **Driver**: `nutdrv_qx` - Generic Q* USB/Serial driver
   - Runs as a daemon process
   - Polls the UPS every 15 seconds (`pollinterval = 15`)
   - Automatically detects battery configuration

2. **Server**: `upsd` - NUT daemon that serves UPS data
   - Listens on `127.0.0.1:3493`
   - Provides data to monitoring clients

3. **Monitor**: `upsmon` - Monitors UPS status and triggers actions
   - Configured as "primary" (directly connected to UPS)
   - User: `monuser`

## Common Issues

### "Data Stale" Problem

**Symptom**: After some time running, `upsc salicru` returns "Error: Data stale" and monitoring stops working.

**Root Cause**: USB autosuspend feature causes the USB device to enter power-saving mode, breaking communication with the UPS driver.

**Solution**: Disable USB autosuspend for the UPS device using udev rules (see `ups.nix`).

The udev rule sets two critical sysfs attributes:
- `power/control = "on"` - Keeps device always powered, prevents automatic suspend
- `power/autosuspend_delay_ms = "0"` - Disables autosuspend timer completely

**Verification after boot**:
```bash
# Check USB power settings
cat /sys/bus/usb/devices/3-2/power/control           # Should show: on
cat /sys/bus/usb/devices/3-2/power/autosuspend_delay_ms  # Should show: 0

# Check UPS communication
upsc salicru  # Should return UPS metrics, not "Data stale"
```

## Useful Commands

### Check UPS Status
```bash
# Get all UPS variables
upsc salicru

# Check specific values
upsc salicru ups.status          # OL = Online, OB = On Battery
upsc salicru battery.charge      # Battery charge percentage
upsc salicru ups.load            # Current load percentage
```

### Service Management
```bash
# Check driver status
systemctl status upsdrv.service

# Check server status
systemctl status upsd.service

# Check monitor status
systemctl status upsmon.service

# Restart all UPS services
systemctl restart upsdrv.service upsd.service upsmon.service
```

### USB Device Information
```bash
# List USB devices
lsusb | grep Cypress

# Detailed device info
lsusb -v -d 0665:5161

# Show all device attributes (useful for udev rules)
udevadm info --attribute-walk --path=/sys/bus/usb/devices/3-2

# Test udev rules for device
udevadm test /sys/bus/usb/devices/3-2
```

### Debugging
```bash
# View driver logs
journalctl -u upsdrv.service -n 50

# View monitor logs for "Data stale" errors
journalctl -u upsmon.service | grep "stale"

# Scan for UPS devices
sudo nut-scanner -U

# Check USB power management status
cat /sys/bus/usb/devices/3-2/power/runtime_status   # Should be: active
```

## Configuration Files

### NixOS Configuration
- **Main config**: `hosts/shared/ups.nix`
- **Generated config**: `/etc/nut/ups.conf` (read-only, managed by NixOS)
- **Udev rules**: `/etc/udev/rules.d/99-local.rules`

### Key Configuration Parameters

```nix
power.ups.ups.salicru = {
  driver = "nutdrv_qx";         # Driver for Voltronic Q* protocol devices
  port = "auto";                 # Auto-detect USB device
  directives = [
    "pollinterval = 15"          # Poll every 15 seconds
  ];
};
```

## Monitoring Integration

The UPS is monitored by Prometheus through the `nut-exporter` running in Kubernetes. The exporter connects to `upsd` on port 3493 and exposes metrics for Grafana dashboards.

**Expected metrics**:
- `network_ups_tools_ups_status`
- `network_ups_tools_battery_charge`
- `network_ups_tools_battery_voltage`
- `network_ups_tools_input_voltage`
- `network_ups_tools_output_voltage`
- `network_ups_tools_ups_load`

If metrics are missing in Grafana, first verify that `upsc salicru` works correctly on the NAS host.

## References

- [NUT Documentation](https://networkupstools.org/docs/)
- [nutdrv_qx driver manual](https://networkupstools.org/docs/man/nutdrv_qx.html)
- [Linux USB Power Management](https://www.kernel.org/doc/Documentation/usb/power-management.txt)
- [udev rules documentation](https://www.freedesktop.org/software/systemd/man/latest/udev.html)
- [Baeldung: Control USB Power Supply](https://www.baeldung.com/linux/control-usb-power-supply)
