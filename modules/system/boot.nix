{ config, lib, pkgs, ... }:
# GPD Pocket 3 Boot Configuration Module
#
# This module optimizes boot performance for the GPD Pocket 3 with:
# - GRUB bootloader configured for portrait display (1200x1920)
# - Fast boot optimizations (systemd initrd, zstd compression)
# - Plymouth splash screen integration
# - Custom kernel parameters for GPD-specific hardware
#
# Boot time target: <10 seconds to login screen
# Key optimizations:
# - Systemd-based initrd (faster than traditional)
# - Zstd compression level -1 (fastest)
# - Disabled network-wait and udev-settle delays
# - Parallel fsck disabled (journaling FS)

{
  # Early kernel modules for GPD Pocket 3 display
  # i915: Intel integrated graphics driver, required for early KMS
  boot.initrd.kernelModules = [ "i915" ];

  boot.loader = {
    # Disable systemd-boot
    systemd-boot.enable = lib.mkForce false;
    
    # Enable GRUB with EFI support
    grub = {
      enable = lib.mkForce true;
      device = "nodev";  # Don't install to MBR
      efiSupport = true;
      useOSProber = false;  # Disable OS prober for simplicity
      configurationLimit = 3;  # Keep only 3 generations (save boot space)
      
      # GPD Pocket 3 - using native portrait orientation
      # Theme uses rotated assets to simulate landscape
      gfxmodeEfi = lib.mkForce "1200x1920x32";  # Native portrait resolution
      gfxmodeBios = lib.mkForce "1200x1920x32";
      gfxpayloadEfi = lib.mkForce "keep";
      gfxpayloadBios = lib.mkForce "keep";
      
      # Extra configuration for GPD Pocket 3
      extraConfig = ''
        # Use native portrait resolution with rotated assets
        set gfxmode=1200x1920x32
        set gfxpayload=keep
        
        # Keep graphics mode for smooth Plymouth transition
        terminal_output gfxterm
        
        # Load video modules for theme
        insmod all_video
        insmod gfxterm
        insmod png
        insmod jpeg
        
        # Adjust font size for readability
        loadfont unicode
        
        # Show menu with countdown
        set timeout_style=menu
        
        # Keep graphics mode through boot
        set linux_gfx_mode=keep
        set gfxpayload=keep
      '';
    };
    
    # EFI settings
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    
    # Timeout for boot menu (1 second for fast boot)
    timeout = 1;
  };
  
  # Fast boot optimizations
  boot.initrd.systemd.enable = true;  # Modern systemd-based initrd (faster)
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 3;

  # Skip waiting for network in initrd
  boot.initrd.network.enable = false;

  # Compress initrd with fastest compression
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = ["-1"];  # Fastest compression level

  # Parallel fsck for faster filesystem checks
  boot.initrd.checkJournalingFS = false;  # Skip fsck on journaling filesystems

  # Optimize systemd boot targets
  systemd.extraConfig = ''
    [Manager]
    DefaultDeviceTimeoutSec=10s
    DefaultTimeoutStartSec=10s
    DefaultTimeoutStopSec=5s
  '';

  # Disable services that slow boot
  systemd.services = {
    NetworkManager-wait-online.enable = false;  # Don't wait for network
    systemd-udev-settle.enable = false;  # Don't wait for udev
  };

  boot.kernelParams = [
    # Fast boot parameters
    "quiet"
    "loglevel=3"
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=auto"
    "systemd.show_status=auto"
    "rd.quiet"

    # Plymouth
    "plymouth.enable=1"
    "vt.global_cursor_default=0"

    # Skip unnecessary waits
    "nowatchdog"  # Disable hardware watchdog (faster boot)
    # "mitigations=off" removed - security over speed

    # GPD Pocket 3 display
    "fbcon=rotate:1"
    "video=DSI-1:panel_orientation=right_side_up"
  ];
}