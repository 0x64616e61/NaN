{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.autoRotate;
in
{
  options.custom.hm.desktop.autoRotate = {
    enable = mkEnableOption "auto-rotate screen in Hyprland";
    
    monitor = mkOption {
      type = types.str;
      default = "eDP-1";
      description = "Monitor to rotate";
    };
    
    scale = mkOption {
      type = types.float;
      default = 1.0;
      description = "Monitor scale to maintain during rotation";
    };
  };

  config = mkIf cfg.enable {
    # Create systemd user service for auto-rotate
    systemd.user.services.auto-rotate-gpd = {
      Unit = {
        Description = "Automatic screen rotation for GPD Pocket 3";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.auto-rotate-gpd or "/run/current-system/sw/bin/auto-rotate-gpd"} ${cfg.monitor} ${toString cfg.scale}";
        Restart = "always";
        RestartSec = 5;
        # Add delay before starting to ensure everything is ready
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
      };
      
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
    
    # Also ensure it restarts after Hyprland is fully loaded
    wayland.windowManager.hyprland.settings.exec-once = [
      "${pkgs.bash}/bin/bash -c 'sleep 10 && systemctl --user restart auto-rotate-gpd'"
    ];
  };
}