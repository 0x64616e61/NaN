# Nix-on-Droid Troubleshooting

## Initial Setup Hanging

If Nix-on-Droid hangs on first launch with "evaluating derivation", try:

### Option 1: Wait and Force Close
1. Force close the app after 10 minutes
2. Reopen Nix-on-Droid
3. It often works on second launch

### Option 2: Clear and Retry
1. Go to Android Settings → Apps → Nix-on-Droid
2. Clear Storage (this removes all Nix data)
3. Launch Nix-on-Droid again
4. Let it bootstrap with default config first

### Option 3: Use Termux First
If Nix-on-Droid won't start:
1. Install Termux from F-Droid (not Play Store!)
2. In Termux, run:
   ```bash
   pkg update
   pkg install curl
   sh <(curl -L https://nixos.org/nix/install)
   ```
3. Then try Nix-on-Droid again

## Common Issues

### "No space left on device"
- Nix-on-Droid needs ~2GB free space minimum
- Check: Settings → Storage
- Clear cache from other apps if needed

### Network timeouts
- Switch between WiFi and mobile data
- Some carriers block Nix cache servers
- Try with VPN if available

### Bootstrap alternatives
Instead of the full config, you can bootstrap with minimal packages:
```bash
# Just get a basic shell working first
nix-on-droid switch --flake "github:nix-community/nix-on-droid#minimal"

# Then upgrade to our config
nix-on-droid switch --flake "github:0x64616e61/nix-modules?dir=nix-on-droid#default"
```

## GrapheneOS Specific

GrapheneOS might need:
1. Ensure Storage Scopes permission is granted
2. Check if Exploit Protection Compatibility Mode needs to be enabled for Nix-on-Droid
3. Try disabling Memory Tagging Extension (MTE) for the app if crashes occur

## Last Resort

If nothing works, use the Nix-on-Droid bootstrap zip:
1. Download bootstrap from: https://github.com/nix-community/nix-on-droid/releases
2. Extract to `/data/data/com.termux.nix/files/`
3. Launch Nix-on-Droid