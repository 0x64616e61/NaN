{ pkgs, ... }:

{
  imports = [
    ./hardware
    ./power
    ./security
    ./packages
    ./input
    ./wayland-screenshare.nix
    ./boot.nix
    ./plymouth.nix
    ./monitor-config.nix
    ./grub-theme.nix
    ./workflows-symlink.nix
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
      enable = true;  # Enable auto-rotation for GPD Pocket 3
      monitor = "DSI-1";  # GPD Pocket 3 DSI display
      scale = 1.5;  # Maintain 1.5x scale during rotation
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
    
    # Email packages
    packages.email = {
      enable = true;  # Enable Proton Bridge and Thunderbird
    };
    
    # SuperClaude Framework
    packages.superclaude = {
      enable = true;  # Enable SuperClaude AI-enhanced development framework
      installGlobally = true;
    };
    
    # Keyboard remapping with keyd
    input.keyd = {
      enable = true;  # Enable keyd for advanced keyboard customization
    };
    
    # Wayland screen sharing support
    waylandScreenshare = {
      enable = true;  # Enable screen sharing for Electron apps (Slack, Teams, etc.)
    };
    
    # GRUB theme with globe style
    grubTheme = {
      enable = true;  # Enable custom GRUB theme matching Plymouth globe animation
    };
  };

  # Packages that don't fit into modules
  environment.systemPackages = with pkgs; [
    ghostty
    youtube-tui
    openvpn
    gptfdisk
    vial
    parted
    gh
    chromium 
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
