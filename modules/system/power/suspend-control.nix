{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.power.suspendControl;
in
{
  options.custom.system.power.suspendControl = {
    enable = mkEnableOption "advanced suspend control";
    
    disableCompletely = mkOption {
      type = types.bool;
      default = false;
      description = "Completely disable all suspend/sleep functionality";
    };
    
    ignoreSuspendKey = mkOption {
      type = types.bool;
      default = false;
      description = "Ignore hardware suspend button";
    };
    
    ignoreHibernateKey = mkOption {
      type = types.bool;
      default = false;
      description = "Ignore hardware hibernate button";
    };
    
    disableIdleAction = mkOption {
      type = types.bool;
      default = false;
      description = "Disable automatic suspend on idle";
    };
    
    disableLowBatterySuspend = mkOption {
      type = types.bool;
      default = false;
      description = "Disable automatic suspend on critical battery";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Basic suspend key handling
    (mkIf (cfg.ignoreSuspendKey || cfg.ignoreHibernateKey || cfg.disableIdleAction) {
      services.logind.extraConfig = ''
        ${optionalString cfg.ignoreSuspendKey "HandleSuspendKey=ignore"}
        ${optionalString cfg.ignoreHibernateKey "HandleHibernateKey=ignore"}
        ${optionalString cfg.disableIdleAction "IdleAction=ignore"}
      '';
    })
    
    # Complete suspend disable
    (mkIf cfg.disableCompletely {
      systemd.targets = {
        sleep.enable = false;
        suspend.enable = false;
        hibernate.enable = false;
        "hybrid-sleep".enable = false;
        "suspend-then-hibernate".enable = false;
      };
      
      systemd.services = {
        "systemd-suspend".enable = false;
        "systemd-hibernate".enable = false;
        "systemd-hybrid-sleep".enable = false;
        "systemd-suspend-then-hibernate".enable = false;
      };
    })
    
    # Disable low battery suspend
    (mkIf cfg.disableLowBatterySuspend {
      services.upower = {
        enable = true;
        criticalPowerAction = "Ignore";
        allowRiskyCriticalPowerAction = true;
      };
    })
  ]);
}