{ config, lib, pkgs, ... }:

with lib;

let
  # GPD tools source directory
  gpdToolsDir = "/home/a/nix-modules/src/gpd-tools";

  # Complete system startup script that launches all GPD tools
  gpd-complete-script = pkgs.writeShellScript "gpd-complete-system" ''
    #!/usr/bin/env bash
    # GPD Complete System - Reboot Safe
    # Launches all GPD positioning tools in correct order

    echo "Starting GPD Complete System..."

    # Start iio-hyprland rotation daemon
    if [ -x "${gpdToolsDir}/build-permanent/iio-hyprland" ]; then
      "${gpdToolsDir}/build-permanent/iio-hyprland" &
      echo "✓ Started iio-hyprland rotation daemon"
      sleep 2
    else
      echo "⚠ iio-hyprland not found at ${gpdToolsDir}/build-permanent/iio-hyprland"
    fi

    # Start waybar positioning
    if [ -x "${gpdToolsDir}/fixed-waybar-positioning.sh" ]; then
      "${gpdToolsDir}/fixed-waybar-positioning.sh" &
      echo "✓ Started waybar positioning"
      sleep 1
    else
      echo "⚠ fixed-waybar-positioning.sh not found"
    fi

    # Start window physical pinning
    if [ -x "${gpdToolsDir}/window-physical-pinning.sh" ]; then
      "${gpdToolsDir}/window-physical-pinning.sh" &
      echo "✓ Started window physical pinning"
    else
      echo "⚠ window-physical-pinning.sh not found"
    fi

    echo "GPD Complete System Started"

    # Keep the service running by waiting for all background processes
    wait
  '';
in
{
  options = {
    custom.system.gpdCompleteSystem = {
      enable = mkEnableOption "GPD Complete System integration (iio-hyprland + waybar + window pinning)";
    };
  };

  config = mkIf config.custom.system.gpdCompleteSystem.enable {
    # Create systemd user service for GPD Complete System
    systemd.user.services.gpd-complete = {
      enable = true;
      description = "GPD Complete System (Reboot Safe)";
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        ExecStart = "${gpd-complete-script}";
        Restart = "on-failure";
        RestartSec = "10";
        # Resource limits
        MemoryMax = "512M";
        CPUQuota = "50%";
        # Environment variables
        Environment = [
          "TERM=xterm-256color"
          "WAYLAND_DISPLAY=wayland-1"
        ];
      };
    };
  };
}
