# Nix-on-Droid Configuration for Pixel 9 Pro

Optimized mobile development environment that complements the GPD Pocket 3 setup.

## 📱 Features

### Core Development Tools
- **Editor**: Neovim with Catppuccin theme
- **Shell**: Zsh with starship prompt
- **Version Control**: Git with GitHub CLI
- **Languages**: Node.js, Python3, GCC

### Modern CLI Utilities
- `ripgrep` (rg) - Fast grep replacement
- `fd` - Fast find replacement
- `bat` - Cat with syntax highlighting
- `eza` - Modern ls with icons
- `zoxide` - Smart directory navigation
- `fzf` - Fuzzy finder
- `btop` - Resource monitor

### Connectivity
- **SSH**: Pre-configured for GPD access
  - `gpd` - Via WiFi hotspot (10.42.0.1)
  - `gpd-usb` - Via USB tethering
  - `mini` - Via Tailscale
- **Syncthing**: File sync with GPD
- **Tailscale**: Secure networking

## 🚀 Installation

1. Install Nix-on-Droid from F-Droid
2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/nix-modules.git
   cd nix-modules/nix-on-droid
   ```

3. Build and switch:
   ```bash
   nix-on-droid switch --flake .#pixel9pro
   ```

## ⚙️ Usage

### Quick Commands
- `rebuild` - Apply configuration changes
- `update` - Update flake inputs
- `clean` - Garbage collect Nix store

### Git Shortcuts
- `gs` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push

### Navigation
- `z [directory]` - Smart cd with zoxide
- `ll` - List files with icons
- `tree` - Tree view with icons

### Connect to GPD
```bash
# Via hotspot
gpd

# Via Tailscale (most reliable)
mini

# Check sync status
sync-status
```

## 📂 Syncthing Setup

1. Start Syncthing on phone:
   ```bash
   # Syncthing runs automatically
   # Access web UI at http://localhost:8384
   ```

2. Add GPD device using its Syncthing ID

3. Share these folders:
   - `~/Documents` - Shared documents
   - `~/Projects` - Development projects
   - `~/Scripts` - Utility scripts
   - `~/Sync` - General sync

## 🎨 Theme

Terminal uses Catppuccin Mocha theme (same as GPD) for consistency.

## 📝 Notes

- Configuration is completely separate from GPD's NixOS
- No desktop environment or GUI packages (mobile-optimized)
- All tools match GPD setup for muscle memory
- SSH connection reuse enabled for faster access
- Compression enabled for mobile networks