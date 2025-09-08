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
  
  # Boot configuration with Plymouth
  boot.initrd.verbose = false;
  boot.kernelParams = [
    # Quiet boot with Plymouth animation (ESC to toggle messages)
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    
    # Plymouth specific - animation mode with ESC toggle
    "plymouth.enable=1"
    "vt.global_cursor_default=0"  # Hide cursor
    
    # Fix console rotation for GPD Pocket 3
    "fbcon=rotate:1"
    "video=DSI-1:panel_orientation=right_side_up"
  ];
}