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
      configurationLimit = 10;  # Keep 10 generations
      
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
    
    # Timeout for boot menu (5 seconds to see menu)
    timeout = 5;
  };
  
  # Boot configuration with Plymouth - silent boot
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 3;  # NixOS silent boot setting
  boot.kernelParams = [
    # Silent boot with Plymouth (ESC to toggle messages)
    # Order matters: quiet must come first
    "quiet"
    "loglevel=3"  # Balanced suppression - 0 might break Plymouth
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=auto"  # Auto mode for Plymouth compatibility
    "systemd.show_status=auto"
    "rd.quiet"
    
    # Plymouth specific - animation mode with ESC toggle
    "plymouth.enable=1"
    "vt.global_cursor_default=0"  # Hide cursor
    
    # Fix console rotation for GPD Pocket 3
    "fbcon=rotate:1"
    "video=DSI-1:panel_orientation=right_side_up"
  ];
}