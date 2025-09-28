{ config, lib, pkgs, ... }:

with lib;

let
  # Custom GPD waybar positioning tool from existing source
  gpd-waybar-positioner = pkgs.stdenv.mkDerivation {
    name = "gpd-waybar-positioner";
    src = ./../../src/gpd-tools;

    buildInputs = with pkgs; [ gcc ];

    buildPhase = ''
      # Build existing compiled tool
      cp waybar-gpd-positioning gpd-positioner
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp gpd-positioner $out/bin/
    '';
  };

  # Custom iio-hyprland for GPD auto-rotation
  gpd-auto-rotation = pkgs.stdenv.mkDerivation {
    name = "gpd-auto-rotation";
    src = ./../../src/gpd-tools;

    buildInputs = with pkgs; [ gcc meson ninja pkg-config glib dbus ];

    buildPhase = ''
      meson setup build
      ninja -C build
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp build/iio-hyprland $out/bin/gpd-auto-rotation
    '';
  };
in
{
  # Declarative GPD Pocket 3 Physical Positioning Module
  options = {
    custom.system.gpdPhysicalPositioning = {
      enable = mkEnableOption "GPD Pocket 3 physical positioning system";

      autoRotation = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic rotation based on accelerometer";
      };

      waybarPhysicalPinning = mkOption {
        type = types.bool;
        default = true;
        description = "Pin waybar to physical edge during rotation";
      };

      windowPhysicalPinning = mkOption {
        type = types.bool;
        default = true;
        description = "Preserve window physical positions during rotation";
      };
    };
  };

  config = mkIf config.custom.system.gpdPhysicalPositioning.enable {
    # Install GPD positioning tools
    environment.systemPackages = [
      gpd-waybar-positioner
      gpd-auto-rotation
    ];

    # Declarative auto-rotation service
    systemd.user.services.gpd-auto-rotation = mkIf config.custom.system.gpdPhysicalPositioning.autoRotation {
      enable = true;
      description = "GPD Auto-Rotation (Declarative)";
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = pkgs.writeShellScript "gpd-auto-rotation-reboot-safe" ''
          #!/usr/bin/env bash
          # REBOOT-SAFE: Dynamic system variable pattern
          sys="gcc meson ninja pkg-config glib dbus coreutils"

          # Dynamically ensure rotation tool is available
          if [ -x "${gpd-auto-rotation}/bin/gpd-auto-rotation" ]; then
            nix-shell -p $sys --run '${gpd-auto-rotation}/bin/gpd-auto-rotation'
          else
            echo "GPD auto-rotation tool not available"
            exit 1
          fi
        '';
        Restart = "always";
        RestartSec = "5";
        Type = "simple";
        # Enhanced restart policies and resource limits
        MemoryMax = "256M";
        CPUQuota = "25%";
        Environment = [
          "TERM=xterm-256color"
          "WAYLAND_DISPLAY=wayland-1"
        ];
      };
    };

    # Declarative waybar physical positioning
    systemd.user.services.gpd-waybar-positioning = mkIf config.custom.system.gpdPhysicalPositioning.waybarPhysicalPinning {
      enable = true;
      description = "GPD Waybar Physical Edge Pinning (Declarative)";
      wantedBy = [ "default.target" ];
      after = [ "waybar.service" ];

      serviceConfig = {
        ExecStart = pkgs.writeShellScript "gpd-waybar-positioning-reboot-safe" ''
          #!/usr/bin/env bash
          # REBOOT-SAFE: Dynamic system variable pattern
          sys="gcc coreutils"

          # Dynamically ensure waybar positioner is available
          if [ -x "${gpd-waybar-positioner}/bin/gpd-positioner" ]; then
            nix-shell -p $sys --run '${gpd-waybar-positioner}/bin/gpd-positioner'
          else
            echo "GPD waybar positioner tool not available"
            exit 1
          fi
        '';
        Restart = "always";
        RestartSec = "3";
        Type = "simple";
        # Enhanced restart policies and resource limits
        MemoryMax = "128M";
        CPUQuota = "20%";
        Environment = [
          "TERM=xterm-256color"
          "WAYLAND_DISPLAY=wayland-1"
        ];
      };
    };

    # Hardware sensor support for GPD
    hardware.sensor.iio.enable = true;

    # Ensure proper permissions for GPD hardware access
    users.users.a.extraGroups = [ "input" "video" ];
  };
}