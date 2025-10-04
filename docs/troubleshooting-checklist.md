# 5-Minute Troubleshooting Checklist

Quick diagnostic steps for common issues. Work through the relevant section when something goes wrong.

---

## 🚨 System Won't Boot

**Symptoms:** Black screen, stuck at GRUB, kernel panic

### Quick Fixes
- [ ] **Boot previous generation** - Hold `Space` at GRUB menu, select older generation
- [ ] **Check GRUB menu** - Verify generations are listed (if not, reinstall bootloader)
- [ ] **Safe mode** - Select generation with fallback kernel

### Diagnostic Commands (from live USB)
```bash
# Mount system and check logs
mount /dev/nvme0n1p2 /mnt  # Adjust partition as needed
journalctl --directory=/mnt/var/log/journal -b -1 | grep -i error

# Check last successful boot
ls -lt /mnt/nix/var/nix/profiles/system-*-link | head -5
```

### Common Causes
- **New kernel incompatibility** → Boot older generation
- **Broken bootloader config** → Reinstall: `nixos-install --no-root-password`
- **Full disk** → Free space: `nix-collect-garbage -d`

---

## 🔧 Rebuild Fails

**Symptoms:** `nixos-rebuild` exits with error, configuration won't apply

### Step 1: Check Syntax
```bash
# Validate flake syntax
cd /nix-modules
nix flake check --show-trace

# Look for obvious errors
grep -n "}" configuration.nix | head -20  # Check balanced braces
```

### Step 2: Verify Build Flags
```bash
# ❌ WRONG - will fail on hardware detection
sudo nixos-rebuild switch --flake .#NaN

# ✅ CORRECT - includes --impure flag
sudo nixos-rebuild switch --flake .#NaN --impure
```

### Step 3: Test Without Switching
```bash
# Build but don't activate (safe)
sudo nixos-rebuild test --flake .#NaN --impure

# Dry-run to see what would change
sudo nixos-rebuild dry-build --flake .#NaN --impure
```

### Step 4: Check for Conflicts
```bash
# Assertions will show up as errors
# Look for messages like: "assertion failed at..."

# Common conflicts:
# - Multiple rotation modules enabled
# - Duplicate service definitions
# - Missing required options
```

### Step 5: Check Disk Space
```bash
df -h /nix

# If < 1GB free, clean up
nix-collect-garbage -d
sudo nix-collect-garbage -d
```

### Error Message Decoder

| Error Message | Likely Cause | Fix |
|---------------|--------------|-----|
| `error: getting status of '/etc/nixos/hardware-configuration.nix': No such file` | Missing `--impure` flag | Add `--impure` to rebuild command |
| `assertion '...rotation...' failed` | Multiple rotation modules enabled | Disable conflicting modules in config |
| `error: builder for '...' failed` | Package build failure | Check `nixos-rebuild build` for details |
| `error: infinite recursion encountered` | Circular module import | Review module imports, check for loops |

---

## 🖥️ Display Issues

**Symptoms:** Wrong resolution, black screen, no rotation

### Screen Not Rotating

```bash
# Check accelerometer device
ls /sys/bus/iio/devices/
cat /sys/bus/iio/devices/iio:device0/name  # Should show "mxc4005" or similar

# Check rotation service status
systemctl --user status auto-rotate-both

# View rotation service logs
journalctl --user -u auto-rotate-both -n 50

# Restart rotation service
systemctl --user restart auto-rotate-both

# Check Hyprland socket connection
echo $HYPRLAND_INSTANCE_SIGNATURE
ls /run/user/1000/hypr/
```

**If service shows connection errors:**
```bash
# Restart Hyprland session (logs out!)
hyprctl dispatch exit

# Or restart just the service with new socket
systemctl --user restart auto-rotate-both
```

### Wrong Resolution/Scale

```bash
# Check active monitors
hyprctl monitors

# Manually set monitor config
hyprctl keyword monitor "DSI-1,1200x1920@60,0x0,1.5,transform,3"

# Check configuration file
cat ~/.config/hypr/monitors.conf

# Verify system config
grep -A 5 "custom.system.monitor" /nix-modules/modules/system/default.nix
```

### Monitor Not Detected

```bash
# List all displays
wlr-randr

# Check kernel detection
dmesg | grep -i display
dmesg | grep -i dsi

# Verify Hyprland is running
ps aux | grep Hyprland
```

---

## 🔒 Fingerprint Not Working

**Symptoms:** Fingerprint reader not recognized, authentication fails

### Check Device Exists
```bash
# Verify device node
ls -l /dev/focal_moh_spi

# If missing, check kernel module
lsmod | grep focal_spi

# Check dmesg for errors
dmesg | grep -i focal
dmesg | grep -i fingerprint
```

### Check Service Status
```bash
# fprintd should be running
systemctl status fprintd

# Restart service
sudo systemctl restart fprintd

# Check for errors
journalctl -u fprintd -n 50
```

### Re-enroll Fingerprint
```bash
# Delete old enrollments
fprintd-delete $USER

# Enroll new fingerprint
fprintd-enroll

# Test enrollment
fprintd-verify

# Verify PAM config
cat /etc/pam.d/swaylock | grep fprintd
cat /etc/pam.d/sudo | grep fprintd
```

### Module Not Loading
```bash
# Check if module is enabled in config
grep -r "focaltechFingerprint" /nix-modules/modules/system/

# Manually load module (temporary)
sudo modprobe focal_spi

# Check kernel ring buffer
dmesg | tail -20
```

---

## 🔄 Auto-Commit Failing

**Symptoms:** `update!` command hangs or fails, git push errors

### Check Git Status
```bash
cd /nix-modules
sudo git status

# Check for uncommitted changes
sudo git diff --stat
```

### Verify GitHub Authentication
```bash
# Check GitHub CLI auth
gh auth status

# Re-authenticate if needed
gh auth login

# Test SSH connection
ssh -T git@github.com
# Should see: "Hi username! You've successfully authenticated..."
```

### Manual Commit/Push
```bash
cd /nix-modules
sudo git add -A
sudo git commit -m "Manual commit: $(date)"
sudo git push origin main
```

### Check Remote Configuration
```bash
# Verify remote URL
sudo git remote -v

# Should show:
# origin  git@github.com:0x64616e61/nix-modules.git (fetch)
# origin  git@github.com:0x64616e61/nix-modules.git (push)

# Fix if using HTTPS instead of SSH
sudo git remote set-url origin git@github.com:0x64616e61/nix-modules.git
```

---

## ⚡ Performance Issues

**Symptoms:** Slow boot, high CPU usage, system lag

### Check CPU Temperature
```bash
# Current temp
cat /sys/class/thermal/thermal_zone5/temp  # Divide by 1000 for °C

# Monitor real-time
watch -n 1 'cat /sys/class/thermal/thermal_zone5/temp | awk "{print \$1/1000\"°C\"}"'

# Check thermal throttling
journalctl -u thermald -n 50
```

### Check Power Profile
```bash
# Current profile
power-profile

# Switch to performance
power-profile performance

# Switch to power save
power-profile powersave

# Battery status
battery-status
```

### Check Running Services
```bash
# List all user services
systemctl --user list-units --type=service

# Check failed services
systemctl --user --failed

# Check system services
systemctl --failed
```

### Memory Usage
```bash
# Check memory
free -h

# Top memory consumers
ps aux --sort=-%mem | head -10

# Check swap usage
swapon --show
```

---

## 🎮 Hyprland Issues

**Symptoms:** Compositor crashes, windows not responding, input lag

### Check Hyprland Process
```bash
# Is Hyprland running?
ps aux | grep Hyprland

# Check Hyprland logs
journalctl --user -t Hyprland -n 100

# Test hyprctl connection
hyprctl version
```

### Reload Configuration
```bash
# Reload without restart
hyprctl reload

# Check for config errors
cat ~/.config/hypr/hyprland.conf | grep -i error
```

### Plugin Issues
```bash
# List loaded plugins
hyprctl plugins list

# Check hyprgrass plugin
hyprctl plugins list | grep hyprgrass

# Unload problematic plugin
hyprctl plugin unload /path/to/plugin.so
```

### Reset to Defaults
```bash
# Backup current config
cp -r ~/.config/hypr ~/.config/hypr.backup

# Let system rebuild regenerate config
sudo nixos-rebuild switch --flake /nix-modules/.#NaN --impure
```

---

## 🌐 Network Issues

**Symptoms:** No internet, DNS failures, slow connection

### Check Connection
```bash
# Ping test
ping -c 3 1.1.1.1  # Cloudflare DNS
ping -c 3 google.com  # DNS + connectivity

# Check network interfaces
ip addr show

# Check default route
ip route show
```

### DNS Issues
```bash
# Test DNS resolution
nslookup google.com

# Check DNS config
cat /etc/resolv.conf

# Restart NetworkManager
sudo systemctl restart NetworkManager
```

---

## 🔄 Update Issues

**Symptoms:** `nix flake update` fails, packages won't update

### Update Flake Inputs
```bash
cd /nix-modules

# Update all inputs
nix flake update

# Update specific input
nix flake update hydenix
nix flake update nixpkgs

# Check input status
nix flake metadata
```

### Clear Flake Cache
```bash
# Clear evaluation cache
rm -rf ~/.cache/nix/eval-cache-v*

# Rebuild with fresh evaluation
sudo nixos-rebuild switch --flake .#NaN --impure --refresh
```

---

## 🆘 Emergency Recovery

**When all else fails:**

### Option 1: Rollback
```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or use panic command
panic  # Interactive with confirmation
```

### Option 2: Reset to GitHub
```bash
cd /nix-modules
sudo git fetch origin
sudo git reset --hard origin/main
sudo nixos-rebuild switch --flake .#NaN --impure
```

### Option 3: Boot from USB
1. Boot from NixOS live USB
2. Mount system partition
3. chroot into system
4. Rollback or fix config
5. Reboot

### Option 4: Nuclear Option
```bash
# Clean everything and rebuild from scratch
nix-collect-garbage -d
sudo nix-collect-garbage -d
sudo nixos-rebuild switch --flake .#NaN --impure --refresh
```

---

## 📋 Diagnostic Information to Collect

**When asking for help, include:**

```bash
# System info
nixos-version
uname -a

# Hardware info
lspci -nn
lsusb

# Current generation
ls -l /nix/var/nix/profiles/system

# Recent logs
journalctl -b -p err -n 50

# Flake info
cd /nix-modules && nix flake metadata

# Configuration snippet (the problematic section)
cat /nix-modules/modules/system/default.nix | grep -A 10 "problemOption"
```

---

## 🔗 Additional Resources

- **Full Troubleshooting Guide:** [troubleshooting.md](./troubleshooting.md)
- **FAQ:** [faq.md](./faq.md)
- **Navigation Hub:** [NAVIGATION.md](./NAVIGATION.md)
- **GitHub Issues:** [Submit bug report](https://github.com/0x64616e61/nix-modules/issues)

---

**Last Updated:** 2025-10-01
