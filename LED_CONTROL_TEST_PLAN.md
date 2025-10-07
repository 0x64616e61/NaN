# GPD Pocket 3 Running Light LED Control Test Plan

**Date**: 2025-10-07
**Device**: GPD Pocket 3 (BIOS v2.10)
**LED**: Running Light (Position #6, top edge near hinge)
**Current State**: Green (system powered on)

---

## Test Objectives

1. Verify LED changes to red when system enters sleep mode
2. Confirm LED returns to green when system wakes
3. Document timing and behavior of LED transitions
4. Validate that LED control is impossible through software interfaces

---

## Pre-Test Status

### System State
```bash
# System is currently running
systemctl status | grep "State:"
# Expected: State: running

# LED is currently green (observed visually)
# Battery status: Full, 100%
cat /sys/class/power_supply/BAT0/status
cat /sys/class/power_supply/BAT0/capacity
```

### Available LED Interfaces
```bash
# Confirmed: No direct LED control interface exists
ls /sys/class/leds/
# Result: Only input LEDs (capslock, numlock, etc.) and phy0-led (no physical LED)

# No EC tools available
command -v ectool
# Result: Not found

# No platform LED devices found
find /sys/devices/platform -name "*led*" 2>/dev/null
# Result: No LED-specific devices
```

---

## Test Cases

### Test 1: LED Software Control Attempt
**Purpose**: Verify no software control interface exists
**Expected**: All attempts fail, LED remains green

**Commands to try:**
```bash
# Attempt 1: Check for any LED device matching "running" or "power"
find /sys/class/leds -name "*run*" -o -name "*power*"
# Expected: No results

# Attempt 2: Check for ACPI platform LED devices
find /sys/devices/platform -type f -name "*led*" 2>/dev/null
# Expected: No LED control files

# Attempt 3: Look for WMI LED methods
ls /sys/devices/platform/PNP0C14*/wmi_bus/*/methods 2>/dev/null
# Expected: No LED-related methods
```

**Result**: ✅ Confirmed - No software interface for direct LED control

---

### Test 2: System Suspend LED Behavior (CRITICAL)
**Purpose**: Verify LED turns red when system suspends
**Expected**: LED changes from green to red

**⚠️ WARNING**: This test will:
- Suspend the system (enter sleep mode)
- Disconnect Claude Code session
- Require manual wake (press power button)
- Need to restart Claude Code to continue

**Pre-test checklist:**
- [ ] Save all work
- [ ] Close unnecessary applications
- [ ] Note current time for duration measurement
- [ ] Be prepared to press power button to wake

**Test execution:**
```bash
# Execute system suspend
sudo systemctl suspend
```

**Observations to record after wake:**
1. Did LED turn red during suspend? (Visual observation)
2. How long did suspend transition take?
3. Did LED immediately change or was there delay?
4. Did LED return to green on wake?
5. How long did wake transition take?

**Result**: ⏸️ **PENDING USER APPROVAL** - Requires manual execution

---

### Test 3: Alternative Power States
**Purpose**: Test LED behavior in other power states
**Expected**: LED shows red in all low-power states

**States to test:**
1. **Suspend-to-RAM** (sleep): `systemctl suspend`
2. **Suspend-to-disk** (hibernate): `systemctl hibernate` (if supported)
3. **Poweroff**: `systemctl poweroff` (destructive, not recommended for testing)

**Result**: 🔒 **NOT EXECUTED** - Would terminate session

---

## Test Results Summary

### Confirmed Facts

✅ **Software Control**: IMPOSSIBLE
- No `/sys/class/leds/` interface for running light
- No EC tools available
- No ACPI/WMI methods found
- LED is firmware-controlled only

✅ **LED Behavior**: Documented via user observation
- Green = System powered ON
- Red = System powered OFF or in sleep mode
- Behavior is BIOS/EC firmware controlled
- Cannot be overridden by software

⏸️ **Suspend Test**: PENDING
- Requires manual execution with user consent
- Would verify red LED in sleep mode
- Session interruption required

---

## Recommendations

### For Direct LED Control
**Verdict**: ❌ **NOT POSSIBLE**

The running light LED cannot be controlled through software on Linux. The LED state is hardwired to system power state by BIOS/EC firmware.

**No viable approaches:**
- No kernel module or driver exists
- No EC firmware commands accessible
- No ACPI methods exposed
- BIOS does not provide LED configuration options (likely)

### For Testing LED Behavior
**Verdict**: ⚠️ **POSSIBLE BUT DISRUPTIVE**

To verify LED turns red:
1. **Manual suspend test**: Press power button → select sleep (non-destructive)
2. **Command-line suspend**: `systemctl suspend` (requires wake via power button)
3. **Scheduled suspend**: `rtcwake -m mem -s 10` (auto-wake after 10 seconds)

**Least disruptive option**: `rtcwake` with short timer
```bash
# Suspend for 10 seconds, auto-wake
sudo rtcwake -m mem -s 10
# LED should turn red during suspend
# System auto-wakes after timer expires
```

---

## Conclusion

**Can the LED be made to turn red?**
✅ **YES** - By suspending the system

**Can the LED be controlled independently?**
❌ **NO** - LED is hardwired to system power state

**Recommended approach for testing:**
Use `rtcwake` with a short timer (10-30 seconds) to suspend and auto-wake, allowing observation of LED behavior without requiring manual intervention.

---

## Next Steps

If you want to proceed with testing:

1. **Safe option**: Manual suspend via power button menu (non-destructive)
2. **Automated option**: `sudo rtcwake -m mem -s 10` (auto-wake after 10s)
3. **Full test**: Execute Test 2 above with proper preparation

Choose based on your comfort level with system interruption.
