# NixOS Rebuild Instructions - Cleanup Modules Added

**Date**: 2025-10-06
**Status**: ✅ Configuration updated, ⏳ Rebuild required
**Issue**: Interactive sudo authentication required (cannot run from Claude Code)

---

## What Changed

Added SuperClaude Framework cleanup automation to configuration.nix:

```nix
# SuperClaude Framework - Automated cleanup and monitoring
./.claude/cleanup-automation.nix # Daily /tmp cleanup, weekly Nix GC
./.claude/disk-space-monitor.nix # Hourly disk space monitoring
```

**Changes verified**: See `git diff configuration.nix` above

---

## Why Manual Rebuild Required

**Root Cause**: Claude Code runs in non-interactive mode without TTY access

**Authentication Flow**:
1. `sudo nixos-rebuild` requires authentication
2. Fingerprint reader prompts: "Place your finger on the fingerprint reader"
3. Timeout after no response: "Verification timed out"
4. Falls back to password: "sudo: a terminal is required to read the password"
5. **FAILS**: No interactive terminal available in Claude Code context

**Solution**: Run rebuild command manually in your terminal where fingerprint/password authentication works.

---

## Manual Rebuild Steps

### Option 1: Quick Update (Recommended)

Run in your terminal (not Claude Code):

```bash
cd /home/a/nix-modules
update!
```

**What it does**:
1. Auto-commits changes with timestamp
2. Pushes to GitHub
3. Runs `sudo nixos-rebuild switch --flake .#NaN --impure`
4. Prompts for fingerprint/password authentication interactively

### Option 2: Test First (Safer)

```bash
cd /home/a/nix-modules

# Test without activation (safe, no system changes)
rebuild-test

# If successful, apply changes
update!
```

### Option 3: Manual Commands

```bash
cd /home/a/nix-modules

# Commit changes
git add configuration.nix
git commit -m "feat: add SuperClaude cleanup automation modules"
git push

# Rebuild system
sudo nixos-rebuild switch --flake .#NaN --impure
```

---

## What Will Be Activated

### 1. cleanup-automation.nix

**Systemd Services & Timers**:

- **nix-garbage-collect.service** (Weekly)
  - Deletes Nix generations >30 days old
  - Optimizes Nix store (deduplication)
  - Reports final store size

- **tmp-cleanup.service** (Daily)
  - Removes files in /tmp older than 7 days
  - Preserves system directories (.X11-unix, etc.)

- **journal-cleanup.service** (Weekly)
  - Limits systemd journal to 500MB
  - Keeps last 7 days

- **user-cache-cleanup.service** (Weekly)
  - Cleans ~/.cache directories
  - Removes old build artifacts

- **claude-cleanup.service** (Weekly)
  - Removes old Claude Code artifacts
  - Cleans temporary analysis files

### 2. disk-space-monitor.nix

**Systemd Service & Timer**:

- **disk-space-monitor.service** (Hourly)
  - Monitors /tmp (threshold: 10GB)
  - Monitors Nix store (threshold: 100GB)
  - Monitors root filesystem (threshold: 200GB)
  - Detects stuck nix-shell processes
  - Logs warnings when thresholds exceeded

---

## Verification After Rebuild

Once rebuild completes successfully, verify services are active:

```bash
# Check timer schedules
systemctl list-timers | grep -E "nix-garbage|tmp-cleanup|disk-space|journal|claude"

# Expected output (times will vary):
# NEXT                        LEFT          LAST  PASSED  UNIT
# Sun 2025-10-06 14:00:00 UTC 1h 52min left n/a   n/a     disk-space-monitor.timer
# Mon 2025-10-07 00:00:00 UTC 11h left      n/a   n/a     tmp-cleanup.timer
# Sun 2025-10-13 00:00:00 UTC 6d left       n/a   n/a     nix-garbage-collect.timer
# Sun 2025-10-13 00:00:00 UTC 6d left       n/a   n/a     journal-cleanup.timer
# Sun 2025-10-13 00:00:00 UTC 6d left       n/a   n/a     user-cache-cleanup.timer
# Sun 2025-10-13 00:00:00 UTC 6d left       n/a   n/a     claude-cleanup.timer

# Verify service status
systemctl status disk-space-monitor.service
systemctl status tmp-cleanup.service

# Check logs
journalctl -u disk-space-monitor.service -n 20
journalctl -u tmp-cleanup.service -n 20
```

---

## Immediate /tmp Cleanup (Optional)

The automated cleanup runs daily, but you can clean /tmp immediately:

```bash
# Manual cleanup of identified files
sudo rm -rf /tmp/nix-shell-300466-0
sudo rm -rf /tmp/nix-modules-backup
sudo rm -rf /tmp/nix-shell-{1054,2214,629519,87554}-0
sudo rm -rf /tmp/node-compile-cache

# Verify space recovered
du -sh /tmp
```

---

## Troubleshooting

### Build Fails

```bash
# Check syntax errors
nix flake check

# View detailed error
sudo nixos-rebuild switch --flake .#NaN --impure --show-trace

# If still failing, rollback
sudo nixos-rebuild switch --rollback
```

### Services Not Starting

```bash
# Check service errors
journalctl -xe | grep -E "nix-garbage|tmp-cleanup|disk-space"

# Manually start service
sudo systemctl start disk-space-monitor.service

# Check status
systemctl status disk-space-monitor.service
```

### Fingerprint Not Working

```bash
# Use password instead
# When prompted, press Ctrl+C on fingerprint and enter password: 7

# Or disable fingerprint temporarily
sudo systemctl stop fprintd
sudo nixos-rebuild switch --flake .#NaN --impure
sudo systemctl start fprintd
```

---

## Expected Outcome

**After successful rebuild**:

✅ Configuration committed and pushed to GitHub
✅ 6 new systemd timers scheduled and active
✅ Automated /tmp cleanup runs daily at midnight
✅ Nix garbage collection runs weekly (Sunday midnight)
✅ Disk space monitoring runs hourly
✅ System logs managed automatically (500MB limit)

**Long-term benefits**:

- Automatic /tmp cleanup prevents accumulation
- Nix store kept optimized (deduplication + old generation removal)
- Proactive disk space monitoring with early warnings
- Reduced manual maintenance overhead

---

## Summary

**Status**: Configuration changes are ready, rebuild requires interactive terminal

**Action Required**: Run `update!` or `rebuild-test` in your terminal (not Claude Code)

**Expected Duration**: 2-5 minutes for rebuild + activation

**Risk Level**: LOW - Safe system module additions, easily reversible with rollback

---

**Created**: 2025-10-06
**Module**: /sc:troubleshoot
**Framework**: SuperClaude 3.777
