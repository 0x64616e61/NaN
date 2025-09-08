{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.hypridle;
in
{
  options.custom.hm.desktop.hypridle = {
    override = mkOption {
      type = types.bool;
      default = false;
      description = "Override hydenix hypridle configuration";
    };
    
    configFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "~/hypridle-custom.conf";
      description = "Custom hypridle config file to use";
    };
    
    screenTimeout = mkOption {
      type = types.int;
      default = 60;
      description = "Seconds before turning off screen";
    };
    
    lockTimeout = mkOption {
      type = types.int;
      default = 120;
      description = "Seconds before locking screen";
    };
    
    suspendTimeout = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "Seconds before suspending (null to disable)";
    };
  };

  config = mkIf cfg.override {
    # Kill and restart hypridle with custom config
    wayland.windowManager.hyprland.settings.exec-once = mkIf (cfg.configFile != null) [
      "pkill hypridle; hypridle -c ${cfg.configFile}"
    ];
    
    # Generate custom config if no file specified
    home.file."hypridle-custom.conf" = mkIf (cfg.configFile == null) {
      text = ''
        listener {
          timeout = ${toString cfg.screenTimeout}
          on-timeout = "hyprctl dispatch dpms off"
          on-resume = "hyprctl dispatch dpms on"
        }
        
        listener {
          timeout = ${toString cfg.lockTimeout}
          on-timeout = "loginctl lock-session"
        }
        
        ${optionalString (cfg.suspendTimeout != null) ''
        listener {
          timeout = ${toString cfg.suspendTimeout}
          on-timeout = "systemctl suspend"
        }
        ''}
      '';
    };
  };
}