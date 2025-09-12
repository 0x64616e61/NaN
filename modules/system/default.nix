{ pkgs, ... }:

{
  imports = [
    ./hardware
    ./power
    ./security
    ./packages
    ./input
    ./services
    ./wayland-screenshare.nix
    ./boot.nix
    ./plymouth.nix
    ./monitor-config.nix
    ./display-management.nix
    ./grub-theme.nix
    ./mpd.nix
    ./ghostty-terminal.nix
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
      provider = "keepassxc";
    };
    
    # Display management tools
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
    
    # Keyboard remapping with keyd
    input.keyd = {
      enable = true;  # Enable keyd for advanced keyboard customization
    };
    
    # Vial keyboard configurator
    input.vial = {
      enable = true;  # Enable Vial with proper udev rules for keyboard configuration
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
    
    # Ghostty terminal persistence
    ghosttyTerminal = {
      enable = true;  # Ensure ghostty remains default terminal
    };
    
    # Unified Remote server
    services.unifiedRemote = {
      enable = true;  # Enable Unified Remote server for mobile control
      port = 9512;
      openFirewall = true;
      autoStart = true;
    };

  };
  # Packages that don't fit into modules
  environment.systemPackages = with pkgs; [
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
  ];

  # System-wide settings
  powerManagement.enable = true;
  powerManagement.powertop.enable = false;
}
