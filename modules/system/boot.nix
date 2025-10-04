{ config, lib, pkgs, ... }:

{
  # Disable grub2-themes since we're using custom theme
  boot.loader.grub2-theme = {
    enable = false;
  };

  # Early kernel modules for GPD Pocket 3 display
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
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "10s";
    DefaultTimeoutStopSec = "5s";
    DefaultDeviceTimeoutSec = "10s";
  };

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