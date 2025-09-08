{ config, lib, pkgs, ... }:

let
  # Custom globe theme package
  customGlobeTheme = pkgs.stdenv.mkDerivation rec {
    pname = "plymouth-theme-custom-globe";
    version = "1.0";
    
    src = ./plymouth-theme/globe;
    
    dontBuild = true;
    
    installPhase = ''
      mkdir -p $out/share/plymouth/themes/globe
      cp -r * $out/share/plymouth/themes/globe/
    '';
  };
in
{
  # Enable Plymouth for smooth boot splash
  boot.plymouth = {
    enable = true;
    
    # Use our custom globe theme
    theme = "globe";
    themePackages = [ customGlobeTheme ];
    
    # Extra configuration for GPD Pocket 3
    extraConfig = ''
      DeviceScale=1
      ShowDelay=0
      Device=/dev/dri/card1
    '';
  };
  
  # Configure initrd for Plymouth
  boot.initrd = {
    verbose = false;  # Hide initrd messages
    
    # Ensure needed modules are loaded early
    availableKernelModules = [ 
      "i915"  # Intel graphics for GPD Pocket 3
      "drm" 
      "drm_kms_helper"
    ];
    
    kernelModules = [ 
      "i915"
      "drm" 
      "drm_kms_helper"
    ];
    
    # Plymouth in initrd for early splash
    systemd.enable = true;  # Use systemd in initrd for better Plymouth integration
  };
  
  # Pass all systemd messages to Plymouth for display
  systemd.services."systemd-fsck@".serviceConfig.StandardOutput = "journal+console";
  systemd.services."systemd-fsck@".serviceConfig.StandardError = "journal+console";
  
  # Ensure Plymouth starts early
  boot.initrd.systemd.services.plymouth-start = {
    wantedBy = [ "initrd.target" ];
    after = [ "systemd-udev-settle.service" ];
    before = [ "initrd-switch-root.target" ];
  };
  
  # Install Plymouth tools
  environment.systemPackages = with pkgs; [
    plymouth
  ];
  
  # Create symlink for DRM device (GPD Pocket 3 uses card1 instead of card0)
  systemd.tmpfiles.rules = [
    "L+ /dev/dri/card0 - - - - /dev/dri/card1"
  ];
}