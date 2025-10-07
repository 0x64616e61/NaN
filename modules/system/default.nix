{ pkgs, ... }:

{
  imports = [
    ./hardware
    ./power
    ./security
    ./packages
    ./input
    ./network
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
    hardware.focaltechFingerprint = {
      enable = true;  # Enable FTE3600 fingerprint reader support
    };

    # ACPI BIOS error fixes
    hardware.acpiFixes = {
      enable = true;  # Enable ACPI DSDT override patches
      useOverride = true;  # Apply SSDT table to fix missing BIOS symbols
    };

    # Thermal management for GPD Pocket 3
    hardware.thermal = {
      enable = true;  # Enable thermal protection
      enableThermald = true;  # Enable Intel thermal daemon
      normalGovernor = "schedutil";  # Balanced governor for better thermals
      emergencyShutdownTemp = 95;  # Emergency shutdown at 95°C
      criticalTemp = 90;  # Critical temperature threshold
      throttleTemp = 80;  # Start throttling at 80°C (lowered from 85°C)
    };

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

    # Security
    security.fingerprint = {
      enable = true;
      enableSddm = true;
      enableSudo = true;
      enableSwaylock = true;
    };

    security.secrets = {
      enable = true;
      provider = "gnome-keyring";  # Required for Spotify and other apps
    };

    security.hardening = {
      enable = true;  # Enable security hardening
      restrictSSH = true;  # SSH key-only authentication
      closeGamingPorts = false;  # Disabled - would need manual port management
    };

    security.secretsManagement = {
      enable = true;  # Enable sops-nix secrets management
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
    # dwl - dwm for Wayland compositor
    dwl
    somebar  # Status bar for dwl

    # Status bar utilities for dwl
    pamixer  # Audio control
    brightnessctl  # Backlight control
    lm_sensors  # Temperature monitoring
    bluez  # Bluetooth support
    procps  # For top command (CPU usage)

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

  # Unified system information display (tree structure)
  system.activationScripts.systemInfo = ''
    echo ""
    echo "GPD Pocket 3 Configuration"
    echo "├─ ACPI Workarounds: TPD0/TPL1, UBTC.RUCC, HEC.SEN4"
    echo "├─ Architecture: Declarative (16MB vs 650MB)"
    echo "└─ Secrets: sops-nix @ /var/lib/sops-nix/key.txt"
    echo ""
  '';
}