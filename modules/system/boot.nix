{ config, lib, pkgs, ... }:

{
  # Disable grub2-themes since we're using custom theme
  boot.loader.grub2-theme = {
    enable = false;
  };

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
        
        # Hide menu by default, show only when shift/esc is held
        set timeout_style=hidden
        
        # Immediately boot and hand off to Plymouth
        set linux_gfx_mode=keep
        set gfxpayload=keep
      '';
    };
    
    # EFI settings
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    
    # Timeout for boot menu (0 for immediate boot, hold shift to show menu)
    timeout = 0;
  };
  
  # Boot configuration with Plymouth (no early messages)
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;  # Hide console messages
  boot.kernelParams = [
    # Quiet boot until Plymouth starts
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "systemd.show_status=plymouth"  # Send systemd messages to Plymouth
    "rd.systemd.show_status=false"  # Hide direct console output
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    
    # Plymouth specific - enable with messages
    "plymouth.enable=1"
    "vt.global_cursor_default=0"  # Hide cursor
    
    # Fix console rotation for GPD Pocket 3
    "fbcon=rotate:1"
    "video=DSI-1:panel_orientation=right_side_up"
  ];
}