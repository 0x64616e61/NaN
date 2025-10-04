# System Architecture

Visual overview of the nix-modules configuration structure, module relationships, and data flow.

---

## System Architecture Overview

```mermaid
graph TB
    subgraph "Entry Points"
        A[flake.nix] --> B[configuration.nix]
        B --> C[hardware-config.nix]
    end

    subgraph "System Modules (custom.system.*)"
        B --> D[modules/system/default.nix]
        D --> E[hardware/]
        D --> F[power/]
        D --> G[security/]
        D --> H[packages/]
        D --> I[network/]
    end

    subgraph "User Modules (custom.hm.*)"
        B --> J[modules/hm/default.nix]
        J --> K[applications/]
        J --> L[desktop/]
        J --> M[audio/]
        J --> N[hyprland/]
        J --> O[waybar/]
    end

    subgraph "Core Features"
        E --> E1[auto-rotate.nix]
        E --> E2[focal-spi/]
        E --> E3[thermal-management.nix]
        E --> E4[monitoring.nix]

        F --> F1[battery-optimization.nix]
        F --> F2[lid-behavior.nix]
        F --> F3[suspend-control.nix]

        G --> G1[fingerprint.nix]
        G --> G2[secrets.nix]

        L --> L1[hyprgrass-config.nix]
        L --> L2[hypridle.nix]
        L --> L3[auto-rotate-service.nix]
    end

    style A fill:#f9f,stroke:#333,stroke-width:3px
    style B fill:#f9f,stroke:#333,stroke-width:3px
    style E1 fill:#ff9,stroke:#333
    style L3 fill:#ff9,stroke:#333
    style G1 fill:#9f9,stroke:#333
```

---

## Configuration Flow

```mermaid
sequenceDiagram
    participant U as User
    participant F as flake.nix
    participant C as configuration.nix
    participant S as System Modules
    participant H as Home Manager
    participant N as NixOS

    U->>F: nixos-rebuild switch --flake .#NaN --impure
    F->>C: Load main configuration
    C->>C: Import hardware-config.nix
    C->>S: Import modules/system/
    C->>H: Import modules/hm/
    S->>N: Generate system configuration
    H->>N: Generate user environment
    N->>N: Build system closure
    N->>U: Activate new generation
```

---

## Module Dependency Graph

```mermaid
graph LR
    subgraph "System Layer"
        A[monitor-config.nix] --> B[hardware/auto-rotate.nix]
        C[hardware/thermal-management.nix] --> D[hardware/monitoring.nix]
        E[power/battery-optimization.nix] --> F[power/lid-behavior.nix]
    end

    subgraph "User Layer"
        G[desktop/auto-rotate-service.nix] --> B
        H[desktop/hyprgrass-config.nix] --> I[hyprland/default.nix]
        J[waybar/default.nix] --> G
    end

    subgraph "Core Services"
        B --> K[systemd: auto-rotate-both]
        E --> L[systemd: battery-monitor]
        M[security/fingerprint.nix] --> N[PAM Integration]
    end

    style B fill:#ff9,stroke:#333,stroke-width:2px
    style G fill:#ff9,stroke:#333,stroke-width:2px
    style K fill:#9ff,stroke:#333
    style L fill:#9ff,stroke:#333
```

---

## Hardware Stack

```mermaid
graph TB
    subgraph "Hardware Abstraction"
        A[GPD Pocket 3 Hardware] --> B[Kernel Modules]
        B --> C[Device Nodes]
    end

    subgraph "NixOS Modules"
        C --> D[hardware/focal-spi/]
        C --> E[hardware/auto-rotate.nix]
        C --> F[hardware/thermal-management.nix]
    end

    subgraph "System Services"
        D --> G[systemd: fprintd]
        E --> H[systemd: auto-rotate-both]
        F --> I[systemd: thermald]
    end

    subgraph "User Applications"
        G --> J[PAM: swaylock/sudo]
        H --> K[Hyprland: monitor rotation]
        I --> L[Waybar: temp display]
    end

    style A fill:#faa,stroke:#333,stroke-width:2px
    style D fill:#afa,stroke:#333,stroke-width:2px
    style E fill:#afa,stroke:#333,stroke-width:2px
    style F fill:#afa,stroke:#333,stroke-width:2px
```

---

## Screen Rotation System

**Problem:** Multiple modules handle rotation - which is active?

```mermaid
graph TB
    A[iio:device0 Accelerometer] --> B{Rotation System}

    B --> C[hardware/auto-rotate.nix]
    B --> D[desktop/auto-rotate-service.nix]
    B --> E[gpd-physical-positioning.nix]
    B --> F[packages/display-rotation.nix]

    C --> G[systemd service]
    D --> H[user service]
    E --> I[system service]

    G --> J[hyprctl monitor transform]
    H --> J
    I --> J

    J --> K[Hyprland Display]

    style A fill:#faa,stroke:#333,stroke-width:2px
    style C fill:#ff9,stroke:#333
    style D fill:#ff9,stroke:#333
    style E fill:#ff9,stroke:#333
    style F fill:#ff9,stroke:#333
    style J fill:#9f9,stroke:#333,stroke-width:2px
    style K fill:#9f9,stroke:#333,stroke-width:2px

    L[NOTE: Multiple modules conflict!] --> B
    style L fill:#f99,stroke:#f00,stroke-width:2px
```

**Current Status:** Multiple rotation implementations exist. Recommended: Use `custom.hm.desktop.autoRotateService.enable = true` (user service) or `custom.system.hardware.autoRotate.enable = true` (system service), not both.

---

## Boot Process Flow

```mermaid
sequenceDiagram
    participant GRUB
    participant Kernel
    participant Init
    participant SystemD
    participant Services
    participant Hyprland

    GRUB->>Kernel: Load kernel + initrd
    Kernel->>Init: Start systemd
    Init->>SystemD: Mount filesystems
    SystemD->>Services: Start system services
    Services->>Services: Load kernel modules (focal_spi)
    Services->>Services: Start thermald
    Services->>Services: Start fprintd
    SystemD->>Hyprland: Start display manager (SDDM)
    Hyprland->>Hyprland: Load monitor configuration
    Hyprland->>Services: Start user services
    Services->>Services: auto-rotate-both.service
    Services->>Services: waybar
```

---

## Package Management Architecture

```mermaid
graph TB
    subgraph "Package Sources"
        A[nixpkgs] --> D[Nix Store]
        B[hydenix] --> D
        C[Local overlays] --> D
    end

    subgraph "Package Categories"
        D --> E[System Packages]
        D --> F[User Packages]
    end

    subgraph "Installation Locations"
        E --> G[/run/current-system/sw/bin/]
        F --> H[~/.nix-profile/bin/]
    end

    subgraph "Module Definitions"
        I[modules/system/default.nix] --> E
        J[modules/hm/default.nix] --> F
        K[modules/system/packages/] --> E
    end

    style D fill:#9f9,stroke:#333,stroke-width:2px
```

---

## Service Architecture

### System Services (root)

```mermaid
graph LR
    A[systemd.services] --> B[nixos-update.service]
    A --> C[fix-hyprland-monitor.service]
    A --> D[fprintd.service]
    A --> E[thermald.service]
    A --> F[battery-monitor.service]

    B --> G[Auto-commit + rebuild]
    C --> H[Monitor orientation fix]
    D --> I[Fingerprint authentication]
    E --> J[Thermal management]
    F --> K[Battery optimization]
```

### User Services

```mermaid
graph LR
    A[systemd.user.services] --> B[auto-rotate-both.service]
    A --> C[waybar.service]
    A --> D[hypridle.service]
    A --> E[easyeffects.service]

    B --> F[Screen rotation]
    C --> G[Status bar]
    D --> H[Idle management]
    E --> I[Audio effects]
```

---

## File System Layout

```
/nix-modules/
├── flake.nix                      # Flake definition, inputs, outputs
├── configuration.nix              # Main system config (user, hostname, etc.)
├── hardware-config.nix            # Smart hardware detection wrapper
├── modules/
│   ├── system/                    # System-level modules (custom.system.*)
│   │   ├── default.nix           # Aggregator (292 lines)
│   │   ├── hardware/
│   │   │   ├── auto-rotate.nix   # ✅ Recommended rotation module
│   │   │   ├── focal-spi/        # FTE3600 fingerprint support
│   │   │   ├── thermal-management.nix
│   │   │   └── monitoring.nix
│   │   ├── power/
│   │   │   ├── battery-optimization.nix
│   │   │   ├── lid-behavior.nix
│   │   │   └── suspend-control.nix
│   │   ├── security/
│   │   │   ├── fingerprint.nix   # PAM integration
│   │   │   └── secrets.nix       # KeePassXC
│   │   └── packages/
│   │       ├── superclaude.nix
│   │       ├── claude-code.nix
│   │       └── mcp/
│   └── hm/                        # Home Manager modules (custom.hm.*)
│       ├── default.nix           # Aggregator (155 lines)
│       ├── applications/
│       ├── audio/
│       ├── desktop/
│       │   ├── auto-rotate-service.nix  # ✅ User rotation service
│       │   ├── hyprgrass-config.nix
│       │   └── hypridle.nix
│       ├── hyprland/             # Hyprland config (212 lines)
│       └── waybar/               # Waybar config (298 lines)
├── docs/                          # Documentation
│   ├── NAVIGATION.md             # 📍 Start here
│   ├── troubleshooting-checklist.md
│   ├── migration.md
│   └── architecture.md           # 👈 You are here
└── .claude/                       # SuperClaude framework
```

---

## Data Flow: User Command to System Change

```mermaid
graph TB
    A[User: update!] --> B[Shell Alias]
    B --> C[systemd: nixos-update.service]
    C --> D[Git: Commit changes]
    D --> E[Git: Push to GitHub]
    E --> F[nixos-rebuild switch]
    F --> G[Nix: Evaluate flake.nix]
    G --> H[Nix: Build system closure]
    H --> I[Nix: Activate new generation]
    I --> J[systemd: Restart changed services]
    J --> K[User sees new system]

    style A fill:#f9f,stroke:#333,stroke-width:2px
    style C fill:#9ff,stroke:#333
    style F fill:#ff9,stroke:#333
    style I fill:#9f9,stroke:#333,stroke-width:2px
```

---

## Input Validation Flow (NEW)

With the UX improvements, modules now validate inputs:

```mermaid
graph TB
    A[User Configuration] --> B{Module Options}

    B --> C[Type Checking]
    C --> D{Valid Type?}
    D -->|No| E[Error: Wrong type]
    D -->|Yes| F[Range Validation]

    F --> G{In Range?}
    G -->|No| H[Error: Out of range]
    G -->|Yes| I[Assertion Checks]

    I --> J{Conflicts?}
    J -->|Yes| K[Error: Module conflict]
    J -->|No| L[Configuration Valid]

    L --> M[Build System]

    style E fill:#f99,stroke:#f00
    style H fill:#f99,stroke:#f00
    style K fill:#f99,stroke:#f00
    style L fill:#9f9,stroke:#333,stroke-width:2px
```

**Example Validations:**
- `scale`: Must be 0.5-3.0
- `transform`: Must be 0, 1, 2, or 3
- `resolution`: Must match format `WIDTHxHEIGHT@REFRESH`
- **Conflicts:** Cannot enable both `autoRotate` and `gpdPhysicalPositioning.autoRotation`

---

## Security Model

```mermaid
graph TB
    subgraph "User Space"
        A[User: a] --> B[Shell Aliases]
        A --> C[User Services]
    end

    subgraph "Privilege Boundary"
        B --> D{Requires Root?}
        D -->|Yes| E[Polkit Rules]
        D -->|No| F[Execute Directly]
        E --> G[Systemd Service]
    end

    subgraph "System Space"
        G --> H[nixos-rebuild]
        G --> I[Git Operations]
        C --> J[Hyprland Commands]
    end

    style E fill:#ff9,stroke:#333,stroke-width:2px
    style G fill:#9ff,stroke:#333,stroke-width:2px
```

**Security Improvements:**
- ❌ OLD: Hardcoded `echo 7 | sudo -S` in scripts
- ✅ NEW: Polkit rules + systemd services (no password in code)

---

## Module Lifecycle

```mermaid
stateDiagram-v2
    [*] --> Disabled: Module exists
    Disabled --> Enabled: enable = true
    Enabled --> Configured: Set options
    Configured --> Validated: Build time
    Validated --> Active: After rebuild
    Active --> Modified: Change options
    Modified --> Validated: Rebuild
    Active --> Disabled: enable = false
    Disabled --> [*]: Module removed
```

---

## Troubleshooting Flow

```mermaid
graph TB
    A[Issue Occurs] --> B{Check Logs}
    B --> C[journalctl -xe]
    C --> D{Service Failed?}

    D -->|Yes| E[systemctl status SERVICE]
    D -->|No| F{Hardware Issue?}

    E --> G{Module Conflict?}
    G -->|Yes| H[Disable conflicting module]
    G -->|No| I[Check module config]

    F -->|Yes| J[Check device nodes]
    F -->|No| K{Config Error?}

    K -->|Yes| L[nix flake check --show-trace]
    L --> M[Fix syntax/assertions]

    J --> N[Verify kernel module loaded]
    N --> O[lsmod, dmesg]

    H --> P[Rebuild]
    I --> P
    M --> P
    O --> P

    P --> Q{Build Success?}
    Q -->|Yes| R[Test new config]
    Q -->|No| A

    R --> S{Issue Resolved?}
    S -->|Yes| T[Done!]
    S -->|No| U[Rollback: panic or --rollback]

    style T fill:#9f9,stroke:#333,stroke-width:2px
    style U fill:#f99,stroke:#f00,stroke-width:2px
```

---

## Integration Points

### Hydenix Framework Integration

```mermaid
graph LR
    A[hydenix flake input] --> B[configuration.nix]
    B --> C[hydenix.* options]
    C --> D[hydenix.hm.* options]

    C --> E[System: Audio]
    C --> F[System: Boot]
    C --> G[System: Network]

    D --> H[User: Hyprland]
    D --> I[User: Git]
    D --> J[User: Shell]
```

### SuperClaude Framework Integration

```mermaid
graph TB
    A[.claude/ directory] --> B[CORE/]
    A --> C[LEFT_BRANCH/tests/]
    A --> D[RIGHT_BRANCH/workflows/]

    B --> E[RULES.md]
    B --> F[PRINCIPLES.md]
    B --> G[MCP_*.md]

    E --> H[Claude Code Behavior]
    F --> H
    G --> I[MCP Servers]

    I --> J[Sequential Thinking]
    I --> K[Morphllm Transform]
    I --> L[Context7 Docs]

    style A fill:#f9f,stroke:#333,stroke-width:2px
```

---

## Performance Characteristics

### Build Times

```
Cold build (no cache):     ~15-20 minutes
Warm build (cached):       ~2-3 minutes
Incremental (small change):  ~30-60 seconds
```

### Service Startup Times

```
auto-rotate-both:          ~2s (waits for accelerometer)
fprintd:                   <1s
thermald:                  <1s
waybar:                    ~1s
Hyprland:                  ~2-3s
```

---

## Future Architecture Improvements

**Planned (based on UX audit):**

1. **Rotation Consolidation** - Merge 19 rotation modules into single implementation
2. **Auto-Documentation** - Generate options.html from module definitions
3. **Module Deprecation System** - Clear migration paths for old modules
4. **Automated Testing** - NixOS VM tests for each module
5. **CI/CD Pipeline** - Automated docs and testing on push

---

## Additional Resources

- **Module Documentation:** [Options Reference](./options-reference.md)
- **Configuration Guide:** [NAVIGATION.md](./NAVIGATION.md)
- **Developer Guide:** [CLAUDE.md](../CLAUDE.md)
- **Troubleshooting:** [troubleshooting-checklist.md](./troubleshooting-checklist.md)

---

**Last Updated:** 2025-10-01
**Diagram Tool:** Mermaid.js (renders in GitHub/most markdown viewers)
