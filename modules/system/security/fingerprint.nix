{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.security.fingerprint;
in
{
  options.custom.system.security.fingerprint = {
    enable = mkEnableOption "fingerprint authentication";
    
    enableSddm = mkOption {
      type = types.bool;
      default = true;
      description = "Enable fingerprint auth for SDDM login";
    };
    
    enableSudo = mkOption {
      type = types.bool;
      default = true;
      description = "Enable fingerprint auth for sudo commands";
    };
    
    enableSwaylock = mkOption {
      type = types.bool;
      default = true;
      description = "Enable fingerprint auth for swaylock";
    };

    additionalServices = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "polkit-1" "login" ];
      description = "Additional PAM services to enable fingerprint auth for";
    };
  };

  config = mkIf cfg.enable {
    services.fprintd.enable = true;
    
    security.pam.services = mkMerge [
      (mkIf cfg.enableSddm {
        sddm.fprintAuth = true;
      })
      (mkIf cfg.enableSudo {
        sudo.fprintAuth = true;
      })
      (mkIf cfg.enableSwaylock {
        swaylock.fprintAuth = true;
      })
      (listToAttrs (map (service: {
        name = service;
        value = { fprintAuth = true; };
      }) cfg.additionalServices))
    ];
  };
}