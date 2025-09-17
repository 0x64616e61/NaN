# Nix-on-Droid Configuration

This is a Nix-on-Droid configuration that mirrors the CLI tools and customizations from the GPD Pocket 3 NixOS setup, without any graphical components.

## Features

- **All CLI tools from main NixOS config**: git, gh, btop, pandoc, mpv, yt-dlp, and more
- **Catppuccin Mocha theme**: Matching terminal colors and theme
- **Zsh with custom aliases**: Including panic mode (A!, AA!, etc.) for quick git resets
- **Neovim configuration**: With leader key mappings and Catppuccin colors
- **Tmux setup**: Vi mode, custom keybindings, themed status bar
- **Development tools**: Python packages, git configuration matching desktop
- **Modern CLI utilities**: eza, bat, fzf, zoxide, ripgrep

## Prerequisites

1. Install [Nix-on-Droid](https://github.com/nix-community/nix-on-droid) from F-Droid or GitHub releases
2. Ensure you have Termux installed (Nix-on-Droid runs on top of it)

## Installation

### Option 1: Direct Flake Usage (Recommended)

1. Clone this repository or copy the droid folder to your device:
```bash
git clone https://github.com/yourusername/nix-modules.git
cd nix-modules/droid
```

2. Build and activate the configuration:
```bash
nix-on-droid switch --flake .
```

### Option 2: Copy Configuration Files

1. Copy the configuration files to Nix-on-Droid config directory:
```bash
cp -r /path/to/droid/* ~/.config/nix-on-droid/
```

2. Switch to the new configuration:
```bash
nix-on-droid switch --flake ~/.config/nix-on-droid
```

## First Time Setup

After switching to the configuration:

1. **Restart your shell** or source the new configuration:
```bash
exec zsh
```

2. **Verify installations**:
```bash
# Check if tools are available
which btop
which eza
which bat
which nvim
```

3. **Optional: Install Termux API** for clipboard support:
```bash
# In Termux (not Nix-on-Droid shell)
pkg install termux-api
```

## Key Features and Commands

### Shell Aliases

- **Git shortcuts**: `gs` (status), `ga` (add), `gc` (commit), `gp` (push)
- **Navigation**: `..`, `...`, `....` for parent directories
- **Modern replacements**: `ls` → `eza`, `cat` → `bat`
- **Panic mode**: Type `A!` through `AAAAAAAAAAAAAAAAAAAA!` to reset git repo

### Tools Included

**System Monitoring**:
- `btop` - Beautiful system monitor with Catppuccin theme
- `htop` - Classic process viewer
- `neofetch` - System information display

**Development**:
- `git`, `gh` - Version control and GitHub CLI
- `neovim` - Text editor with custom config
- `tmux` - Terminal multiplexer
- Python 3 with pip, setuptools, and common packages

**Media**:
- `mpv` - Media player (can work in terminal with `--vo=tct`)
- `yt-dlp` - YouTube downloader
- `youtube-tui` - Terminal YouTube interface
- `ncmpcpp` - Music player client

**Modern CLI**:
- `eza` - Better ls with icons and git integration
- `bat` - Better cat with syntax highlighting
- `fzf` - Fuzzy finder for files and commands
- `zoxide` - Smarter cd that learns your habits
- `ripgrep` - Fast grep replacement

**Network**:
- `curl`, `wget` - Download tools
- `nmap`, `dig`, `traceroute` - Network diagnostics
- `openvpn` - VPN client
- `signal-cli` - Signal messenger CLI

### Tmux Usage

Default prefix is `Ctrl-a` (not `Ctrl-b`):
- `Ctrl-a |` - Split vertically
- `Ctrl-a -` - Split horizontally
- `Alt-h/j/k/l` - Navigate panes
- `Ctrl-a r` - Reload config

### Neovim Usage

Leader key is `Space`:
- `<Space>w` - Save file
- `<Space>q` - Quit
- `<Space>/` - Clear search highlighting
- `Ctrl-h/j/k/l` - Navigate windows

## Updating

To update the configuration:

```bash
cd /path/to/droid
git pull  # If using git repository
nix-on-droid switch --flake .
```

## Troubleshooting

### Permission Issues

If you encounter permission errors:
```bash
# In Termux
termux-setup-storage
```

### Missing Commands

If commands are not found after switching:
```bash
# Reload shell
exec zsh

# Or manually source
source ~/.zshrc
```

### Flake Errors

If flakes are not enabled:
```bash
nix-on-droid edit  # Add to configuration.nix:
# nix.extraOptions = ''
#   experimental-features = nix-command flakes
# '';
```

## Differences from Desktop Config

This configuration excludes:
- All GUI applications (Firefox, Ghostty GUI, Krita, etc.)
- Wayland/Hyprland components
- Display management tools
- Fingerprint authentication
- Hardware-specific optimizations for GPD Pocket 3

But includes all CLI tools, shell configurations, and terminal-based utilities from the main setup.

## Customization

Edit the following files to customize:
- `home.nix` - User-level packages and program configurations
- `nix-on-droid.nix` - System-level packages and settings
- `flake.nix` - Input sources and overlays

After making changes, apply with:
```bash
nix-on-droid switch --flake .
```