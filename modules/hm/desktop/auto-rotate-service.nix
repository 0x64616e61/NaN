{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.autoRotateService;
in
{
  options.custom.hm.desktop.autoRotateService = {
    enable = mkEnableOption "auto-rotate service for dual monitors with per-display lock";
  };

  config = mkIf cfg.enable {
    # Create systemd user service for auto-rotation
    systemd.user.services.auto-rotate = {
      Unit = {
        Description = "Auto-rotation for GPD Pocket 3 dual display";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        # Use the system-installed auto-rotate script
        ExecStart = "/run/current-system/sw/bin/auto-rotate";
        Restart = "always";
        RestartSec = 5;
        # Add delay before starting to ensure Hyprland is ready
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
