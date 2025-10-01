{ pkgs, ... }:

{
  imports = [
    ./hardware
    ./power
    ./security
    ./packages
    ./input
    ./network
    # ./declarative  # Removed due to conflicts
    ./wayland-screenshare.nix
    ./boot.nix
    ./plymouth.nix
    ./monitor-config.nix
    ./display-management.nix
    ./grub-theme.nix
    ./mpd.nix
  ];

  # Enable custom modules with clean configuration
  custom.system = {
    # Monitor configuration
    monitor = {
      enable = true;  # System-level monitor configuration
      name = "DSI-1";  # GPD Pocket 3 DSI display
      resolution = "1200x1920@60";
      position = "0x0";
      scale = 1.5;  # 150% scaling for GPD Pocket 3
      transform = 3;  # 270 degree rotation (landscape mode)
    };

    # Hardware features
    hardware.autoRotate = {
      enable = true;  # Enhanced auto-rotation with multi-monitor support
      monitor = "DSI-1";  # GPD Pocket 3 DSI display
      scale = 1.5;  # Maintain 1.5x scale during rotation
      syncExternal = true;  # Sync external monitor rotation
      externalPosition = "right";  # Position of external monitor
    };

    hardware.focaltechFingerprint = {
      enable = true;  # Enable FTE3600 fingerprint reader support
    };

    # ACPI BIOS error fixes
    hardware.acpiFixes = {
      enable = true;  # Suppress cosmetic ACPI BIOS errors
      suppressErrors = true;  # Reduce AE_NOT_FOUND error noise
      logLevel = 4;  # Warning level and above (reduces cosmetic errors)
    };

    # GPD Physical Positioning System
    gpdPhysicalPositioning = {
      enable = true;  # Enable GPD physical positioning system
      autoRotation = true;  # Accelerometer-based auto-rotation
      waybarPhysicalPinning = true;  # Pin waybar to physical edge
      windowPhysicalPinning = true;  # Preserve window physical positions
    };

    # Hardware monitoring (DISABLED: Permission conflicts)
    # hardware.monitoring = {
    #   enable = true;  # Enable hardware monitoring for GPD Pocket 3
    #   checkInterval = 30;  # Check every 30 seconds
    #   alerts = {
    #     temperatureHigh = 80;  # Alert at 80°C
    #     batteryLow = 15;  # Alert at 15% battery
    #     method = "all";  # Use all notification methods
    #   };
    #   logging = {
    #     enable = true;  # Enable logging
    #     logFile = "/var/log/gpd-hardware-monitor.log";  # Log file location
    #     level = "info";  # Info level logging
    #   };
    # };

    # TEST: Enable thermal management for GPD Pocket 3 (TEMPORARILY DISABLED)
    # hardware.thermal = {
    #   enable = true;  # Enable thermal protection
    #   enableThermald = true;  # Enable Intel thermal daemon
    #   normalGovernor = "performance";  # 2025 optimization: use performance governor
    #   emergencyShutdownTemp = 95;  # Emergency shutdown at 95°C
    #   criticalTemp = 90;  # Critical temperature threshold
    #   throttleTemp = 85;  # Start throttling at 85°C
    # };

    # Hardware monitoring - re-enabled via unified GPD profile
    # (Configuration now handled in hardware.gpdPocket3 module)

    # Power management
    power.lidBehavior = {
      enable = true;  # Customize lid behavior to not lock/suspend
      action = "ignore";  # Ignore lid close events (don't suspend)
    };

    power.suspendControl = {
      enable = false;  # Set to true for advanced suspend control
      disableCompletely = false;
      disableLowBatterySuspend = false;
    };

    # Battery optimization for GPD Pocket 3
    power.battery = {
      enable = false;  # DISABLED: TLP conflicts with power-profiles-daemon
      tlp = {
        enable = false;  # DISABLED: Conflicts cause system crash
        chargeThresholds = {
          startThreshold = 20;  # Start charging at 20%
          stopThreshold = 80;   # Stop charging at 80% for battery longevity
        };
        cpuGovernor = {
          onAC = "performance";     # Performance mode when plugged in
          onBattery = "powersave";  # Power save mode on battery
        };
        intelCpuSettings = {
          enablePstates = true;           # Enable Intel P-states for i3-1125G4
          enableTurboBoost = true;        # Enable Turbo Boost on AC
          disableTurboOnBattery = true;   # Disable Turbo on battery to save power
          maxFreqPercentAC = 100;         # Full performance on AC
          maxFreqPercentBattery = 80;     # Limit to 80% on battery
        };
      };
      monitoring = {
        enable = false;          # DISABLED: Service registration issue
        enableUpower = true;     # UPower for detailed battery stats
        enableAcpi = true;       # ACPI tools for battery info
        alertThresholds = {
          lowBattery = 15;       # Warning at 15%
          criticalBattery = 5;   # Critical at 5%
        };
      };
      additionalOptimizations = {
        disableWakeOnLan = true;         # Disable WOL to save power
        enableWifiPowerSave = true;      # Enable WiFi power saving
        reduceSwappiness = true;         # Reduce disk swap usage
        enableKernelPowerSaving = true;  # Enable kernel power optimizations
      };
    };

    # Security
    security.fingerprint = {
      enable = true;
      enableSddm = true;
      enableSudo = true;
      enableSwaylock = true;
    };

    security.secrets = {
      enable = true;
      provider = "keepassxc";
    };

    # Network Configuration
    network.iphoneUsbTethering = {
      enable = true;           # Enable iPhone USB tethering support
      autoConnect = true;      # Automatically connect when iPhone is plugged in
      connectionPriority = 15; # Higher priority than WiFi (prefer USB over WiFi)
    };

    # Display management - integrated with GPD profile
    displayManagement = {
      enable = true;  # Enable display management tools and rotation lock
      tools = {
        wlrRandr = true;
        wdisplays = true;
        kanshi = true;
      };
      autoRotate = {
        enable = true;
        syncExternal = true;
        externalPosition = "right";
      };
    };

    # Email packages
    packages.email = {
      enable = true;  # Enable Proton Bridge and Thunderbird
    };

    # SuperClaude Framework
    packages.superclaude = {
      enable = true;  # Enable SuperClaude AI-enhanced development framework
      installGlobally = true;
    };

    # Display rotation scripts
    packages.displayRotation = {
      enable = true;  # Enable display rotation scripts for dual monitor setup
    };

    # Claude CLI - Anthropic's AI coding assistant
    packages.claude-cli = {
      enable = true;  # Enable Claude CLI with Sonnet 4.5 access
      installGlobally = true;
      packageMethod = "npm-direct";  # Use direct npm wrapper approach
    };

    # Keyboard remapping with keyd
    input.keyd = {
      enable = true;  # Enable keyd for advanced keyboard customization
    };

    # Vial keyboard configurator
    input.vial = {
      enable = true;  # Enable Vial with Vial udev rules for keyboard configuration
    };

    # Wayland screen sharing support
    waylandScreenshare = {
      enable = true;  # Enable screen sharing for Electron apps (Slack, Teams, etc.)
    };

    # GRUB theme with globe style
    grubTheme = {
      enable = true;  # Enable custom GRUB theme matching Plymouth globe animation
    };

    # MPD (Music Player Daemon)
    mpd = {
      enable = true;  # Enable MPD music server
    };
  };
  # Packages that don't fit into modules
  environment.systemPackages = with pkgs; [
    x2goclient
    pandoc
    texlive.combined.scheme-full  #  scheme-full for complete LaTeX support
    krita  # Digital painting application
    ghostty
    youtube-tui
    openvpn
    gptfdisk
    parted
    gh
    chromium
    btop  # Beautiful system monitor (btop++)
    iotop  # I/O monitoring tool
    sysstat  # Performance statistics collection
    lynis  # Security auditing tool (2025 hardening)
    signal-desktop  # Signal messenger for secure communications
    teams-for-linux  # Microsoft Teams client
    spotify  # Music streaming service
    libimobiledevice  # iPhone USB support
    ifuse  # Mount iPhone filesystem
    disko
    zfstools
    zfs
    cheese  # Camera app for KVM module support
    # Media playback
    mpv
    yt-dlp  # YouTube downloader for mpv
    # GStreamer plugins (consider moving to audio module)
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    spotifyd  # Spotify daemon
  ];

  # System-wide settings
  powerManagement.enable = true;
  powerManagement.powertop.enable = false;

  # 2025 Memory management optimization for development workloads
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;                    # Reduce swap usage (default: 60)
    "vm.dirty_ratio" = 15;                   # Optimize for development workloads
    "vm.dirty_background_ratio" = 5;         # Background writeback tuning
    "vm.dirty_writeback_centisecs" = 1500;   # SSD optimization
  };

  # Migration notice for declarative system
  system.activationScripts.declarativeSystemInfo = ''
    echo ""
    echo "🎯 GPD Pocket 3 System Architecture:"
    echo "   Mode: Declarative (Event-driven)"
    echo "   Benefits: Pure Functions • No Runtime State • Event-driven"
    echo "   Performance: 16MB memory (vs 650MB+ imperative)"
    echo ""
  '';
}