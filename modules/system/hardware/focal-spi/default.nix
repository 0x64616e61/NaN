{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.hardware.focaltechFingerprint;
  
  # Kernel module for FocalTech FTE3600 SPI fingerprint reader
  focal-spi = config.boot.kernelPackages.callPackage ./kernel-module.nix {};
  
  # Patched libfprint with FocalTech support
  libfprint-focaltech = pkgs.callPackage ./libfprint-focaltech.nix {};
  
  # We'll use the system fprintd with LD_LIBRARY_PATH override
  # since fprintd doesn't have a clean override mechanism
in
{
  options.custom.system.hardware.focaltechFingerprint = {
    enable = mkEnableOption "FocalTech FTE3600 fingerprint reader support";

    debug = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable verbose debug logging for fingerprint service.
        WARNING: Generates excessive logs, use only for troubleshooting.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Add kernel module to extra packages
    boot.extraModulePackages = [ focal-spi ];
    
    # Load the module at boot
    boot.kernelModules = [ "focal_spi" ];
    
    # udev rules for device permissions
    services.udev.extraRules = ''
      # FocalTech fingerprint reader
      SUBSYSTEM=="spi", ATTRS{modalias}=="spi:focal_moh", MODE="0666", GROUP="input", TAG+="uaccess"
      KERNEL=="focal_moh_spi", MODE="0666", GROUP="input", TAG+="uaccess"
    '';
    
    # Enable fprintd service
    services.fprintd.enable = true;
    
    # Add polkit rules for fingerprint authentication
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id.indexOf("net.reactivated.fprint") === 0) {
          return polkit.Result.YES;
        }
      });
    '';
    
    # Add fingerprint auth to PAM services
    security.pam.services = {
      sddm.fprintAuth = true;
      sudo.fprintAuth = true;
      swaylock.fprintAuth = true;
      login.fprintAuth = true;
    };
    
    # systemd override for fprintd to allow device access and use patched libfprint
    systemd.services.fprintd = {
      serviceConfig = {
        DeviceAllow = "/dev/focal_moh_spi rw";
        SupplementaryGroups = [ "input" ];
        Type = "dbus";
        BusName = "net.reactivated.Fprint";
        Restart = "on-failure";
        RestartSec = "1";
      };
      environment = {
        LD_LIBRARY_PATH = "${libfprint-focaltech}/lib";
        LD_PRELOAD = "${libfprint-focaltech}/lib/libfprint-2.so.2";
        G_MESSAGES_DEBUG = "all";
      };
      wantedBy = [ "multi-user.target" ];
    };
    
    # Also make the patched library available system-wide
    environment.systemPackages = [ libfprint-focaltech ];
  };
}