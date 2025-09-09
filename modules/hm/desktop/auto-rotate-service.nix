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
    systemd.user.services.auto-rotate-both = {
      Unit = {
        Description = "Auto-rotation for GPD Pocket 3 with per-display lock support";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "simple";
        # Use the system-installed auto-rotate-both script
        ExecStart = "/run/current-system/sw/bin/auto-rotate-both";
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
