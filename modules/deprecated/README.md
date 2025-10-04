# Deprecated Modules

This directory contains modules that are no longer recommended for use. They are kept for backward compatibility but will be removed in future versions.

## Deprecation Policy

1. **Phase 1: Deprecation Warning** (Current)
   - Module still works but shows warning on activation
   - Documentation updated to recommend alternative
   - Deprecation date announced

2. **Phase 2: Breaking Changes** (v3.0, planned 2026-01-01)
   - Module replaced with assertion that prevents build
   - Clear error message with migration path
   - Old code moved to `deprecated/` directory

3. **Phase 3: Removal** (v4.0, planned 2026-06-01)
   - Module completely removed from repository
   - Only mentioned in CHANGELOG

## Currently Deprecated Modules

| Module | Deprecated | Replacement | Removal Date |
|--------|------------|-------------|--------------|
| `gpd-rotation-service.nix` | 2025-10-01 | `hardware/auto-rotate.nix` or `desktop/auto-rotate-service.nix` | 2026-01-01 |
| `gpd-physical-positioning.nix` | 2025-10-01 | `hardware/auto-rotate.nix` | 2026-01-01 |
| `boot-optimization.nix` | 2025-10-01 | Use systemd boot optimizations | 2026-01-01 |
| `declarative/` | 2025-10-01 | Manual configuration in `default.nix` | 2026-01-01 |

## Migration Guides

### Rotation Modules

**OLD (deprecated):**
```nix
custom.system.gpdPhysicalPositioning = {
  enable = true;
  autoRotation = true;
};
```

**NEW (recommended):**
```nix
# For system-level rotation (runs as root)
custom.system.hardware.autoRotate = {
  enable = true;
  monitor = "DSI-1";
  scale = 1.5;
};

# OR for user-level rotation (recommended)
custom.hm.desktop.autoRotateService = {
  enable = true;
};
```

### Boot Optimization

**OLD (deprecated):**
```nix
custom.system.bootOptimization.enable = true;
```

**NEW (recommended):**
```nix
# Use built-in systemd optimizations
boot.loader.timeout = 1;
systemd.services."systemd-udev-settle".serviceConfig.ExecStart = ["" "${pkgs.coreutils}/bin/true"];
```

## Why Deprecate?

Modules are deprecated when:
- **Duplication**: Multiple modules provide identical functionality
- **Maintenance burden**: Module requires significant upkeep
- **Better alternatives**: Newer module provides superior implementation
- **Conflicts**: Module interferes with other system components
- **Security**: Module contains security issues that can't be fixed

## How to Check for Deprecated Modules

```bash
# Check if you're using deprecated modules
cd /nix-modules
grep -r "gpdPhysicalPositioning\|bootOptimization\|declarative" modules/system/default.nix modules/hm/default.nix

# Build and check for warnings
sudo nixos-rebuild build --flake .#NaN --impure 2>&1 | grep -i deprecated
```

## Questions?

- **Migration help:** See [migration.md](../docs/migration.md)
- **Bug reports:** [GitHub Issues](https://github.com/0x64616e61/nix-modules/issues)
- **General questions:** [FAQ](../docs/faq.md)
