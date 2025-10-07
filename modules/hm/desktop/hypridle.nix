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
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          # Screen timeout - use same toggle-display script as Windows+L keybind
          {
            timeout = cfg.screenTimeout;
            on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
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