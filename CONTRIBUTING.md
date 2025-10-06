# Contributing to NaN

Thank you for your interest in contributing to NaN! This guide will help you add modules, fix bugs, and improve the system.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Adding New Modules](#adding-new-modules)
- [Testing Changes](#testing-changes)
- [Code Style](#code-style)
- [Pull Request Process](#pull-request-process)
- [Module Guidelines](#module-guidelines)

---

## Getting Started

### Prerequisites

- GPD Pocket 3 hardware (or compatible x86_64 device for testing)
- NixOS installation with flakes enabled
- Basic understanding of Nix expression language
- Familiarity with NixOS module system

### Setup Development Environment

1. **Fork and clone**:
   ```bash
   git clone https://github.com/0x64616e61/NaN /etc/nixos
   cd /etc/nixos
   ```

2. **Create development branch**:
   ```bash
   git checkout -b feature/my-new-module
   ```

3. **Test environment**:
   ```bash
   # Test without activating
   sudo nixos-rebuild dry-build --flake .#NaN
   
   # Test with temporary activation (no boot entry)
   sudo nixos-rebuild test --flake .#NaN
   ```

---

## Development Workflow

### Standard Development Cycle

1. **Identify module category**:
   - System-level (needs root): `modules/system/`
   - User-level: `modules/hm/`

2. **Create module file**:
   ```bash
   # System module
   touch modules/system/my-feature.nix
   
   # Home Manager module
   touch modules/hm/applications/my-app.nix
   ```

3. **Implement module** (see [Module Template](#module-template))

4. **Import in parent default.nix**

5. **Enable and test**:
   ```bash
   sudo nixos-rebuild test --flake .#NaN
   ```

6. **Validate** (check logs, test functionality)

7. **Commit changes**:
   ```bash
   git add .
   git commit -m "feat(module): add my-feature module"
   ```

---

## Adding New Modules

### Module Template

```nix
# modules/system/my-feature.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.myFeature;
in
{
  options.custom.system.myFeature = {
    enable = mkEnableOption "My feature description";

    setting1 = mkOption {
      type = types.str;
      default = "default-value";
      description = "Description of setting1";
      example = "example-value";
    };

    setting2 = mkOption {
      type = types.int;
      default = 100;
      description = "Numeric setting description";
    };
  };

  config = mkIf cfg.enable {
    # Package installation
    environment.systemPackages = with pkgs; [
      package-name
    ];

    # Service configuration
    systemd.services.my-service = {
      description = "My service description";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.package-name}/bin/command";
        Restart = "on-failure";
      };
    };

    # Additional configuration
    # ... other config options
  };
}
```

### Importing the Module

Add to `modules/system/default.nix` or `modules/hm/default.nix`:

```nix
{
  imports = [
    # ... existing imports
    ./my-feature.nix
  ];
}
```

### Enabling the Module

In `modules/system/default.nix`:

```nix
custom.system.myFeature = {
  enable = true;
  setting1 = "custom-value";
};
```

---

## Testing Changes

### Test Levels

#### 1. Syntax Validation

```bash
# Check for syntax errors
nix flake check

# Dry-build without activation
sudo nixos-rebuild dry-build --flake .#NaN
```

#### 2. Temporary Activation

```bash
# Test without boot entry (temporary until reboot)
sudo nixos-rebuild test --flake .#NaN

# Check service status
systemctl status my-service

# Check logs
journalctl -xe -u my-service
```

#### 3. Boot Entry Creation

```bash
# Build for next boot (no immediate activation)
sudo nixos-rebuild boot --flake .#NaN

# Reboot and test
sudo reboot
```

#### 4. Full Activation

```bash
# Build, activate, and create boot entry
sudo nixos-rebuild switch --flake .#NaN
```

### Testing Checklist

- [ ] Module enables without errors
- [ ] Services start successfully
- [ ] Configuration files created in correct locations
- [ ] Logs show no errors or warnings
- [ ] Functionality works as expected
- [ ] Doesn't break existing modules
- [ ] Boot time not significantly impacted

---

## Code Style

### Nix Formatting

- **Indentation**: 2 spaces
- **Line length**: Aim for <100 characters
- **Strings**: Use double quotes `"string"`
- **Lists**: Multi-line for >3 items
- **Let bindings**: Group related variables

**Example**:

```nix
let
  cfg = config.custom.system.module;
  myVar = "value";
in
{
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkg1
      pkg2
      pkg3
    ];
  };
}
```

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Module option | camelCase | `myFeature.enableOption` |
| Service name | kebab-case | `my-service` |
| File name | kebab-case | `my-feature.nix` |
| Let bindings | camelCase | `configFile` |

### Comments

```nix
# High-level module explanation at top

options.custom.system.module = {
  # Comment on complex options
  complexOption = mkOption {
    type = types.attrs;
    description = "Detailed description of what this does";
  };
};

config = mkIf cfg.enable {
  # Explain non-obvious configuration
  systemd.services.service = {
    # GPD Pocket 3 specific: requires early start
    wantedBy = [ "multi-user.target" ];
  };
};
```

---

## Module Guidelines

### System vs Home Manager

**Use System Modules** (`modules/system/`) when:
- Root privileges required (kernel modules, services)
- System-wide configuration (udev rules, systemd services)
- Hardware integration (thermal, ACPI, fingerprint)

**Use Home Manager Modules** (`modules/hm/`) when:
- User-specific configuration (dotfiles, themes)
- Applications running as user (browsers, terminals)
- Desktop environment customization

### Option Design

1. **Always provide `enable` option**:
   ```nix
   enable = mkEnableOption "feature description";
   ```

2. **Use appropriate types**:
   ```nix
   types.bool      # true/false
   types.str       # strings
   types.int       # integers
   types.path      # file paths
   types.listOf    # lists
   types.attrs     # attribute sets
   types.enum      # enumeration ["opt1" "opt2"]
   ```

3. **Provide sensible defaults**:
   ```nix
   option = mkOption {
     default = "reasonable-default";
     # ...
   };
   ```

4. **Document thoroughly**:
   ```nix
   option = mkOption {
     description = "Clear explanation of what this does";
     example = "example-value";
   };
   ```

### Hardware-Specific Code

If code is GPD Pocket 3 specific, add comment:

```nix
# GPD Pocket 3: Native portrait display requires 270° rotation
transform = 3;
```

For generic functionality, design for portability:

```nix
# Allow override for other devices
transform = mkOption {
  type = types.int;
  default = 3;  # GPD Pocket 3 default
  description = "Display rotation (0=0°, 1=90°, 2=180°, 3=270°)";
};
```

---

## Pull Request Process

### Before Submitting

1. **Test thoroughly** (see [Testing Changes](#testing-changes))
2. **Check code style** (formatting, naming, comments)
3. **Update documentation**:
   - Add module to `MODULE_API.md`
   - Update `README.md` if needed
   - Add example to `QUICK_REFERENCE.md` if useful

4. **Write descriptive commit message**:
   ```
   feat(security): add AppArmor profile for firefox
   
   - Add custom AppArmor profile for firefox
   - Enable by default in security.hardening module
   - Includes network and file access restrictions
   
   Tested on GPD Pocket 3 with Firefox 121.0
   ```

### PR Title Format

```
type(scope): short description

Types:
- feat: New feature or module
- fix: Bug fix
- docs: Documentation only
- refactor: Code restructuring
- perf: Performance improvement
- test: Testing additions
- chore: Maintenance tasks

Examples:
feat(hardware): add fan control module
fix(thermal): correct temperature threshold logic
docs(api): document power management options
```

### PR Description Template

```markdown
## Description
Brief explanation of changes

## Motivation
Why this change is needed

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Syntax validation (`nix flake check`)
- [ ] Test activation (`nixos-rebuild test`)
- [ ] Service verification
- [ ] Boot test

## Hardware Tested
- GPD Pocket 3 (i7-1195G7, 16GB RAM)

## Additional Notes
Any caveats, known issues, or future improvements
```

### Review Process

1. **Automated checks**: Nix syntax validation
2. **Code review**: Maintainer feedback
3. **Testing**: Verification on hardware
4. **Documentation**: Ensure docs are updated
5. **Merge**: Once approved and tested

---

## Common Development Tasks

### Adding a New Application Module

1. Create `modules/hm/applications/my-app.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   with lib;
   let cfg = config.custom.hm.applications.myApp;
   in {
     options.custom.hm.applications.myApp = {
       enable = mkEnableOption "My application";
     };
     
     config = mkIf cfg.enable {
       home.packages = [ pkgs.my-app ];
       
       xdg.configFile."my-app/config.conf".text = ''
         # Configuration here
       '';
     };
   }
   ```

2. Import in `modules/hm/applications/default.nix`

3. Enable in `modules/hm/default.nix`

### Adding a Hardware Service

1. Create `modules/system/hardware/my-sensor.nix`
2. Implement kernel module loading or udev rules
3. Add systemd service for monitoring
4. Import and enable in `modules/system/default.nix`

### Adding Security Hardening

1. Create module in `modules/system/security/`
2. Add to `security.hardening` options
3. Document security implications
4. Test thoroughly for breakage

---

## Questions?

- **Documentation**: See [MODULE_API.md](MODULE_API.md) and [ARCHITECTURE.md](ARCHITECTURE.md)
- **Issues**: Open an issue on GitHub
- **Discussions**: Use GitHub Discussions for questions

---

## Code of Conduct

- Be respectful and constructive
- Help others learn
- Test your changes thoroughly
- Document your code
- Have fun improving NaN!
