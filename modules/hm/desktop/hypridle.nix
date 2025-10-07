{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.hypridle;
in
{
  options.custom.hm.desktop.hypridle = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable hypridle idle management daemon";
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

  config = mkIf cfg.enable {
    # Enable hypridle service with proper configuration
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "hyprlock";
          before_sleep_cmd = "hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          # Screen timeout - turn off display
          {
            timeout = cfg.screenTimeout;
            on-timeout = "sleep 1 && hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }

          # Lock timeout
          {
            timeout = cfg.lockTimeout;
            on-timeout = "hyprlock";
          }
        ] ++ optional (cfg.suspendTimeout != null) {
          # Suspend timeout (optional)
          timeout = cfg.suspendTimeout;
          on-timeout = "systemctl suspend";
        };
      };
    };

    # Fix systemd environment import for hypridle service
    wayland.windowManager.hyprland.systemd.variables = ["--all"];
  };
}