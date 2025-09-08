# Usage Guide - NixOS Hydenix Configuration

This guide provides detailed instructions for using and customizing your NixOS Hydenix configuration.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Daily Operations](#daily-operations)
3. [Configuration Management](#configuration-management)
4. [Advanced Features](#advanced-features)
5. [Customization Guide](#customization-guide)
6. [Maintenance](#maintenance)

## Quick Start

### Essential Commands

```bash
# Rebuild system (always use --impure for hardware detection)
cd /nix-modules
sudo nixos-rebuild switch --flake .#hydenix --impure

# Test configuration without switching
sudo nixos-rebuild build --flake .#hydenix --impure

# Update from GitHub
sudo git pull origin main
sudo nixos-rebuild switch --flake .#hydenix --impure

# Rollback to previous generation
sudo nixos-rebuild --rollback
```

## Daily Operations

### System Rebuilds

The rebuild process with our configuration:

1. **Automatic hardware detection** - Uses your system's `/etc/nixos/hardware-configuration.nix`
2. **Auto-commit** - Commits any changes before rebuild
3. **GitHub sync** - Pushes changes if authenticated

```bash
# Standard rebuild
cd /nix-modules
sudo nixos-rebuild switch --flake .#hydenix --impure

# Build only (no activation)
sudo nixos-rebuild build --flake .#hydenix --impure

# Dry run (show what would change)
sudo nixos-rebuild dry-activate --flake .#hydenix --impure
```

### Managing Packages

#### System Packages

Edit `configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  vim
  git
  firefox
  # Add your packages here
];
```

#### User Packages (via Home Manager)

Edit `modules/hm/default.nix`:

```nix
home.packages = with pkgs; [
  spotify
  discord
  vscode
  # Add user packages here
];
```

### Working with Git

```bash
# Check status
cd /nix-modules
sudo git status

# Manual commit
sudo git add -A
sudo git commit -m "Description of changes"
sudo git push origin main

# Pull latest changes
sudo git pull origin main

# View commit history
sudo git log --oneline -10
```

## Configuration Management

### File Organization

```
/nix-modules/
├── configuration.nix        # System configuration
├── modules/
│   ├── system/             # System modules
│   │   ├── auto-commit.nix # GitHub auto-sync
│   │   └── custom.nix      # Your custom system modules
│   └── hm/                 # Home Manager modules
│       ├── default.nix     # Main user configuration
│       └── programs/       # Per-program configurations
```

### Creating Custom Modules

#### System Module Example

Create `/nix-modules/modules/system/my-service.nix`:

```nix
{ config, lib, pkgs, ... }:

{
  # Enable a service
  services.myservice = {
    enable = true;
    settings = {
      option1 = "value1";
      option2 = 42;
    };
  };
  
  # Add system packages
  environment.systemPackages = with pkgs; [
    myservice-tools
  ];
}
```

Add to `configuration.nix`:

```nix
imports = [
  ./modules/system/my-service.nix
];
```

#### Home Manager Module Example

Create `/nix-modules/modules/hm/programs/my-app.nix`:

```nix
{ config, lib, pkgs, ... }:

{
  programs.my-app = {
    enable = true;
    settings = {
      theme = "dark";
      fontSize = 14;
    };
  };
  
  home.packages = with pkgs; [
    my-app
  ];
}
```

### Environment Variables

System-wide in `configuration.nix`:

```nix
environment.sessionVariables = {
  EDITOR = "vim";
  BROWSER = "firefox";
};
```

User-specific in `modules/hm/default.nix`:

```nix
home.sessionVariables = {
  CUSTOM_VAR = "value";
};
```

## Advanced Features

### Auto-Commit Module

The auto-commit module (`modules/system/auto-commit.nix`) automatically:
- Detects uncommitted changes
- Commits with timestamp
- Pushes to GitHub using `gh` CLI

To configure:

```bash
# Authenticate GitHub CLI
gh auth login

# Test auto-commit
echo "test" | sudo tee /nix-modules/test.txt
sudo nixos-rebuild switch --flake .#hydenix --impure
# Check if committed and pushed
sudo git log -1
```

To disable auto-commit:
Remove from `configuration.nix`:
```nix
# Comment out or remove this line
# ./modules/system/auto-commit.nix
```

### Hardware Configuration Management

The hardware detection system (`hardware-config.nix`) intelligently:
- Checks for `/etc/nixos/hardware-configuration.nix`
- Uses it when available (with `--impure`)
- Falls back to placeholder for git storage

This means:
- ✅ Pull from GitHub won't break your hardware config
- ✅ Each machine maintains its own hardware settings
- ✅ No manual copying needed

### Hydenix Customization

#### Theme Settings

In `modules/hm/default.nix`:

```nix
hydenix.hm = {
  theme = {
    flavor = "mocha";      # catppuccin flavor
    accent = "blue";        # accent color
    size = "standard";      # standard or compact
  };
};
```

#### Hyprland Configuration

In `modules/hm/hyprland.nix`:

```nix
wayland.windowManager.hyprland = {
  settings = {
    general = {
      gaps_in = 5;
      gaps_out = 10;
      border_size = 2;
    };
    
    decoration = {
      rounding = 10;
      blur = {
        enabled = true;
        size = 3;
      };
    };
    
    animations = {
      enabled = true;
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
    };
    
    # Key bindings
    bind = [
      "$mod, Return, exec, kitty"
      "$mod, Q, killactive"
      "$mod, M, exit"
      "$mod, E, exec, nautilus"
    ];
  };
};
```

### Multi-Machine Setup

For multiple machines, create host-specific configurations:

1. Create host modules:
```bash
/nix-modules/hosts/
├── desktop/
│   └── configuration.nix
├── laptop/
│   └── configuration.nix
└── common/
    └── configuration.nix
```

2. In `flake.nix`, define multiple configurations:
```nix
nixosConfigurations = {
  desktop = nixpkgs.lib.nixosSystem {
    modules = [ ./hosts/desktop/configuration.nix ];
  };
  laptop = nixpkgs.lib.nixosSystem {
    modules = [ ./hosts/laptop/configuration.nix ];
  };
};
```

3. Build for specific host:
```bash
sudo nixos-rebuild switch --flake .#desktop --impure
```

## Customization Guide

### Adding Applications

1. **System-wide** (available to all users):
   ```nix
   # In configuration.nix
   environment.systemPackages = with pkgs; [
     application-name
   ];
   ```

2. **User-specific** (via Home Manager):
   ```nix
   # In modules/hm/default.nix
   home.packages = with pkgs; [
     application-name
   ];
   ```

3. **With configuration**:
   ```nix
   # In modules/hm/programs/app.nix
   programs.application-name = {
     enable = true;
     settings = {
       # App-specific settings
     };
   };
   ```

### Shell Configuration

#### Zsh (default)

In `modules/hm/shell.nix`:

```nix
programs.zsh = {
  enable = true;
  enableCompletion = true;
  autosuggestions.enable = true;
  syntaxHighlighting.enable = true;
  
  shellAliases = {
    ll = "ls -l";
    update = "sudo nixos-rebuild switch --flake /nix-modules#hydenix --impure";
  };
  
  initExtra = ''
    # Custom shell initialization
    export PATH=$HOME/.local/bin:$PATH
  '';
};
```

#### Bash

```nix
programs.bash = {
  enable = true;
  shellAliases = {
    ll = "ls -l";
  };
};
```

### Display Manager and Desktop

The configuration uses Hyprland with SDDM:

```nix
# Already configured in Hydenix
services.xserver.displayManager.sddm.enable = true;
programs.hyprland.enable = true;
```

To customize SDDM theme:

```nix
services.xserver.displayManager.sddm = {
  theme = "breeze";
  settings = {
    Theme = {
      Current = "breeze";
      CursorTheme = "Adwaita";
    };
  };
};
```

## Maintenance

### System Updates

```bash
# Update flake inputs
cd /nix-modules
sudo nix flake update

# Rebuild with updated inputs
sudo nixos-rebuild switch --flake .#hydenix --impure
```

### Garbage Collection

```bash
# Remove old generations (keep last 3)
sudo nix-collect-garbage -d --delete-older-than 7d

# Manual cleanup
sudo nix-collect-garbage -d

# View disk usage
nix-store -q --size /nix/store/*
```

### Generation Management

```bash
# List all generations
sudo nix-env --list-generations -p /nix/var/nix/profiles/system

# Switch to specific generation
sudo nix-env --switch-generation 42 -p /nix/var/nix/profiles/system

# Delete specific generations
sudo nix-env --delete-generations 40 41 42 -p /nix/var/nix/profiles/system
```

### Troubleshooting

#### Rebuild Failures

```bash
# View detailed error
sudo nixos-rebuild switch --flake .#hydenix --impure --show-trace

# Test configuration
sudo nixos-rebuild build --flake .#hydenix --impure

# Check journal for errors
journalctl -xe
```

#### Recovery Mode

If system won't boot:
1. Select older generation in GRUB
2. Fix configuration
3. Rebuild

```bash
# After booting old generation
cd /nix-modules
sudo git checkout HEAD~1  # Revert to previous commit
sudo nixos-rebuild switch --flake .#hydenix --impure
```

#### Reset to GitHub State

```bash
cd /nix-modules
sudo git fetch origin
sudo git reset --hard origin/main
sudo nixos-rebuild switch --flake .#hydenix --impure
```

## Tips and Tricks

### Aliases for Common Commands

Add to your shell configuration:

```bash
alias nrs='sudo nixos-rebuild switch --flake /nix-modules#hydenix --impure'
alias nrb='sudo nixos-rebuild build --flake /nix-modules#hydenix --impure'
alias nfu='cd /nix-modules && sudo nix flake update'
alias ngc='sudo nix-collect-garbage -d'
```

### Testing Changes

1. **Build without switching**:
   ```bash
   sudo nixos-rebuild build --flake .#hydenix --impure
   ```

2. **Dry activation**:
   ```bash
   sudo nixos-rebuild dry-activate --flake .#hydenix --impure
   ```

3. **Test in VM**:
   ```bash
   sudo nixos-rebuild build-vm --flake .#hydenix --impure
   ./result/bin/run-*-vm
   ```

### Performance Optimization

1. **Enable binary caches**:
   ```nix
   nix.settings = {
     substituters = [
       "https://cache.nixos.org"
       "https://hydenix.cachix.org"
     ];
   };
   ```

2. **Parallel building**:
   ```nix
   nix.settings = {
     max-jobs = "auto";
     cores = 0;  # Use all cores
   };
   ```

3. **Optimize store**:
   ```bash
   sudo nix-store --optimise
   ```

---

*For more information, see the [README.md](README.md) or consult the [NixOS Manual](https://nixos.org/manual/nixos/stable/).*
