# GPD Pocket 3 LED Indicator Research

**Date**: 2025-10-07
**Device**: GPD Pocket 3 (i7-1195G7)
**NixOS Version**: 25.05

---

## Summary

The GPD Pocket 3 has **limited software-controllable LED indicators** on Linux. Most LEDs are hardware-controlled by the embedded controller (EC) and not accessible through standard Linux interfaces.

---

## Available LEDs (Software-Controlled)

### 1. WiFi LED (`phy0-led`)
**Location**: `/sys/class/leds/phy0-led/`

**Status**: ✅ **CONTROLLABLE**

```bash
# Current status
cat /sys/class/leds/phy0-led/brightness  # Returns: 0 (off) or 1 (on)
cat /sys/class/leds/phy0-led/max_brightness  # Returns: 1

# Available triggers
cat /sys/class/leds/phy0-led/trigger
# Options: none, phy0rx, phy0tx, phy0assoc, phy0radio

# Control examples
echo 0 > /sys/class/leds/phy0-led/brightness  # Turn off
echo 1 > /sys/class/leds/phy0-led/brightness  # Turn on
echo phy0tx > /sys/class/leds/phy0-led/trigger  # Blink on WiFi transmit
```

**Device Path**: `pci0000:00/0000:00:1c.0/0000:ae:00.0/leds/phy0-led`

---

### 2. Keyboard Status LEDs
**Locations**:
- `/sys/class/leds/input1::capslock` - Caps Lock LED
- `/sys/class/leds/input1::numlock` - Num Lock LED
- `/sys/class/leds/input1::scrolllock` - Scroll Lock LED
- `/sys/class/leds/input27::*` - Virtual keyboard LEDs (keyd)

**Status**: ✅ **CONTROLLABLE** (but managed by keyboard driver)

```bash
# Read current state
cat /sys/class/leds/input1::capslock/brightness  # 0 or 1

# Manual control (not recommended - will be overridden by keyboard state)
echo 1 > /sys/class/leds/input1::capslock/brightness
```

**Note**: These are controlled by keyboard state and shouldn't be manually toggled for normal use.

---

## Unavailable LEDs (Hardware-Controlled)

### 1. Running Light / System Status LED (Top of Device)
**Location**: Top of device, on edge near hinge (Manual Position #6: "Running Light")
**Colors**: Green (powered on), Red (powered off/sleep)

**Status**: ✅ **IDENTIFIED** - BIOS/EC controlled system status indicator with color remapping

**Manual Specification vs Actual Behavior**:
- **Manual says**: White (normal) / Blue (sleep/silent) - system status indicator
- **Actual behavior**: Green (powered on) / Red (powered off/sleep) - system status indicator
- **Purpose unchanged**: Still indicates system power state, only colors changed
- BIOS firmware has remapped LED colors from white/blue → green/red

**Confirmed Behavior** (BIOS v2.10, dated 02/25/2025):
- **Red (solid)**: System powered OFF or during boot (pre-OS)
- **Red (blinking)**: System in suspend/sleep mode
- **Green (solid)**: System fully booted and running OS
- LED transitions from red to green during boot process
- Changes automatically based on system power state
- Controlled entirely by BIOS/EC firmware
- Separate from side charging LED (which is only red when actively charging)

**Technical Details**:
- **NOT** accessible through Linux `/sys/class/leds/` interface
- **NOT** the WiFi LED (`phy0-led` has no physical LED on this device)
- **NOT** related to `input27::misc` (keyd virtual keyboard software LED)
- Embedded Controller (EC) monitors battery status and controls LED directly
- BIOS firmware changed behavior from manual specification (white/blue → red/green)

**Evidence**:
```bash
# Confirmed device state when LED is green
# System is powered on and running
# LED shows GREEN regardless of battery percentage

# BIOS version
cat /sys/class/dmi/id/bios_version  # Returns: 2.10
cat /sys/class/dmi/id/bios_date  # Returns: 02/25/2025

# User observation: "it only shows green when the gpd is on"
# Confirms LED indicates power state, not battery level
```

**Reference**: GPD Support Forum post about LED indicator changes in BIOS v0.23+
https://gpdsupport.com/t/led-indicator-status-changed-in-bios-v-0-23/278

### 2. Charging Indicator LED
**Location**: Side of device, next to USB-C port (Manual Position #5)
**Colors**: Red only (not red/green as some sources suggest)

**Status**: ❌ **NOT CONTROLLABLE** via Linux

**Confirmed Behavior** (BIOS v2.10):
- **Red**: Battery actively charging
- **Off**: Not charging (battery full or unplugged)
- **Manual specification**: Red/Green, but actual behavior is Red/Off only

**Technical Details**:
- Controlled by **Embedded Controller (EC)** firmware
- No sysfs interface found in `/sys/class/leds/`
- No ACPI methods exposed for control
- Directly tied to charging circuitry

**Evidence**:
```bash
# No power LED found in sysfs
find /sys -name "*power*led*" 2>/dev/null
# No results

# Battery status available, but LED control is not
cat /sys/class/power_supply/BAT0/status
# Returns: Full, Charging, Discharging, Not charging

# ACPI battery info available
acpi -V
# Shows battery status, but no LED control interface
```

---

### 2. Display Backlight (Not Technically an "LED")
**Location**: LCD backlight control

**Status**: ✅ **CONTROLLABLE** (via backlight interface, not LED interface)

```bash
# Display backlight control
ls /sys/class/backlight/
# Device: intel_backlight

# Control brightness (0-120000 on GPD Pocket 3)
cat /sys/class/backlight/intel_backlight/brightness
echo 60000 > /sys/class/backlight/intel_backlight/brightness
```

---

## LED Inventory on GPD Pocket 3

| LED Type | Location | Linux Control | Method |
|----------|----------|---------------|--------|
| **Running Light** | Top edge near hinge | ❌ No | BIOS/EC-controlled, green=on, red=off/sleep |
| **Power/Charging** | Power button | ❌ No | EC-controlled |
| **WiFi Activity** | Internal (no physical LED) | ✅ Yes | `/sys/class/leds/phy0-led/` (software only) |
| **Caps Lock** | Keyboard | ✅ Yes | `/sys/class/leds/input*::capslock` |
| **Num Lock** | Keyboard | ✅ Yes | `/sys/class/leds/input*::numlock` |
| **Scroll Lock** | Keyboard | ✅ Yes | `/sys/class/leds/input*::scrolllock` |
| **Display Backlight** | LCD panel | ✅ Yes | `/sys/class/backlight/` |

---

## Why Power LED Is Not Controllable

### 1. Embedded Controller Design
The GPD Pocket 3 uses an **Embedded Controller (EC)** that manages:
- Battery charging logic
- Power delivery
- LED indicators
- Keyboard scanning
- Fan control

The power LED is directly wired to the EC's charging state machine for reliability.

### 2. Safety Considerations
Hardware-controlled charging LEDs are **intentional design** for:
- **Reliability**: Works even if OS crashes or is not booted
- **Safety**: Indicates charging state without software intervention
- **Universality**: Same behavior across all operating systems (Windows/Linux/etc.)

### 3. ACPI Limitations
```bash
# ACPI methods exposed (none for LED control)
find /sys/firmware/acpi -name "*led*" 2>/dev/null
# No results

# No ACPI device for power LED
ls /sys/bus/acpi/devices/ | grep -i led
# No matches
```

---

## Alternative Approaches (Theoretical)

### 1. Custom EC Firmware (Not Recommended)
**Risk**: ⚠️ **EXTREMELY DANGEROUS** - Can brick device

Theoretically, one could:
1. Reverse-engineer the EC firmware
2. Modify charging LED behavior
3. Flash custom EC firmware

**Why not to do this**:
- Voids warranty
- High brick risk
- May violate safety certifications
- EC controls critical charging/power functions

### 2. External USB LED Indicators
Use external USB devices for custom LED control:
```nix
# Example: BlinkStick or similar USB LED device
environment.systemPackages = with pkgs; [
  python3Packages.blinkstick
];
```

### 3. Software-Based Status Indicators
Use desktop notifications or status bar widgets:
```nix
# Battery status notification
systemd.user.services.battery-notify = {
  description = "Battery status notifications";
  script = ''
    while true; do
      status=$(cat /sys/class/power_supply/BAT0/status)
      capacity=$(cat /sys/class/power_supply/BAT0/capacity)
      if [ "$status" = "Charging" ]; then
        notify-send "Battery Charging" "$capacity%"
      elif [ "$status" = "Full" ]; then
        notify-send "Battery Full" "100%"
      fi
      sleep 300  # Check every 5 minutes
    done
  '';
};
```

---

## NixOS Integration for WiFi LED Control

### Module: WiFi LED Control

Create `/etc/nixos/modules/system/hardware/wifi-led-control.nix`:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.hardware.wifiLed;
in
{
  options.custom.system.hardware.wifiLed = {
    enable = mkEnableOption "WiFi LED control";

    trigger = mkOption {
      type = types.enum [ "none" "phy0rx" "phy0tx" "phy0assoc" "phy0radio" ];
      default = "phy0radio";
      description = ''
        WiFi LED trigger mode:
        - none: Manual control only
        - phy0rx: Blink on WiFi receive
        - phy0tx: Blink on WiFi transmit
        - phy0assoc: On when associated to network
        - phy0radio: On when WiFi radio is enabled
      '';
    };

    defaultBrightness = mkOption {
      type = types.int;
      default = 1;
      description = "Default LED brightness (0=off, 1=on)";
    };
  };

  config = mkIf cfg.enable {
    # Set WiFi LED trigger on boot
    systemd.services.wifi-led-setup = {
      description = "Configure WiFi LED behavior";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "wifi-led-setup" ''
          # Wait for LED device to be available
          for i in {1..10}; do
            [ -e /sys/class/leds/phy0-led/trigger ] && break
            sleep 1
          done

          if [ -e /sys/class/leds/phy0-led/trigger ]; then
            echo "${cfg.trigger}" > /sys/class/leds/phy0-led/trigger
            echo "${toString cfg.defaultBrightness}" > /sys/class/leds/phy0-led/brightness
            echo "WiFi LED configured: trigger=${cfg.trigger}, brightness=${toString cfg.defaultBrightness}"
          else
            echo "WiFi LED device not found"
          fi
        '';
      };
    };

    # Utility script for manual control
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "wifi-led" ''
        #!/usr/bin/env bash
        LED_PATH="/sys/class/leds/phy0-led"

        case "$1" in
          on)
            echo 1 > "$LED_PATH/brightness"
            echo "WiFi LED: ON"
            ;;
          off)
            echo 0 > "$LED_PATH/brightness"
            echo "WiFi LED: OFF"
            ;;
          trigger)
            if [ -n "$2" ]; then
              echo "$2" > "$LED_PATH/trigger"
              echo "WiFi LED trigger set to: $2"
            else
              cat "$LED_PATH/trigger"
            fi
            ;;
          status)
            echo "Brightness: $(cat $LED_PATH/brightness)"
            echo "Max brightness: $(cat $LED_PATH/max_brightness)"
            echo "Current trigger: $(cat $LED_PATH/trigger)"
            ;;
          *)
            echo "Usage: wifi-led {on|off|trigger [mode]|status}"
            echo ""
            echo "Trigger modes:"
            echo "  none       - Manual control only"
            echo "  phy0rx     - Blink on WiFi receive"
            echo "  phy0tx     - Blink on WiFi transmit"
            echo "  phy0assoc  - On when associated"
            echo "  phy0radio  - On when WiFi enabled"
            exit 1
            ;;
        esac
      '')
    ];
  };
}
```

### Usage

```nix
# In modules/system/default.nix
custom.system.hardware.wifiLed = {
  enable = true;
  trigger = "phy0tx";  # Blink on WiFi transmit
  defaultBrightness = 1;
};
```

**Commands**:
```bash
# Check status
wifi-led status

# Turn on/off
wifi-led on
wifi-led off

# Change trigger mode
wifi-led trigger phy0tx  # Blink on transmit
wifi-led trigger none    # Manual control
```

---

## Conclusions

### What We Can Control ✅
1. **Keyboard lock LEDs** - Via keyboard driver (Caps/Num/Scroll Lock)
2. **Display backlight** - Via backlight subsystem
3. **WiFi LED (software)** - Full control via sysfs (⚠️ no visible physical LED on GPD Pocket 3)

### What We Cannot Control ❌
1. **Battery status LED (top left keyboard)** - BIOS/EC firmware controlled, shows battery charge state
2. **Power/Charging LED (power button)** - Embedded controller only
3. **No custom RGB LEDs** - Device doesn't have programmable RGB

### Fully Identified ✅
1. **Running Light LED** - Green when powered on, Red when powered off/sleep
   - Location: Top edge near hinge (Position #6)
   - Control: BIOS v2.10+ (EC firmware)
   - Purpose: System power state indicator (color remapped from manual spec)
   - Manual documented white/blue, firmware uses green/red
   - Not software-controllable on Linux

### Recommendations

**For Power Status Indication**:
- Use desktop notifications for charging status
- Use status bar widgets for battery monitoring
- Accept that power LED is hardware-controlled

**For Custom LED Effects**:
- Use WiFi LED for custom signaling (e.g., blink on specific events)
- Use external USB LED devices if more indicators needed
- Use on-screen indicators (eww status bar, dunst notifications)

---

## References

1. **Linux LED Documentation**: https://docs.kernel.org/leds/leds-class.html
2. **GPD Pocket 3 ArchWiki**: https://wiki.archlinux.org/title/GPD_Pocket_3
3. **GPD Support Forum**: https://gpdsupport.com/t/led-indicator-status-changed-in-bios-v-0-23/278
4. **Kernel Source**: `drivers/leds/` in Linux kernel tree

---

**Research Status**: ✅ Complete
**Controllable LEDs**: 1 (WiFi LED via phy0-led)
**Hardware-Only LEDs**: 1 (Power/Charging LED)
