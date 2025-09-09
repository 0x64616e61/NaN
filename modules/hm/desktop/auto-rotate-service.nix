{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.autoRotateService;
in
{
  options.custom.hm.desktop.autoRotateService = {
    enable = mkEnableOption "auto-rotate service for dual monitors";
  };

  config = mkIf cfg.enable {
    # Create systemd user service for auto-rotation
    systemd.user.services.auto-rotate-both = {
      Unit = {
        Description = "Auto-rotation for GPD Pocket 3 with synchronized external monitor";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.auto-rotate-both or "/run/current-system/sw/bin/auto-rotate-both"}";
        Restart = "always";
        RestartSec = 5;
        # Add delay before starting to ensure everything is ready
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
      };
      
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
    
    # Stop the old auto-rotate-gpd service if it exists
    systemd.user.services.auto-rotate-gpd.enable = false;
  };
}
