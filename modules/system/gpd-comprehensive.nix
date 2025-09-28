{ config, lib, pkgs, ... }:

with lib;

let
  # Custom GPD hardware control tool compiled from source
  gpd-hardware-control = pkgs.stdenv.mkDerivation {
    name = "gpd-hardware-control";
    src = /home/a/nix-modules/src/gpd-tools;
    buildInputs = with pkgs; [ gcc ];
    buildPhase = ''
      gcc -o gpd-hardware-control gpd-hardware-control.c
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp gpd-hardware-control $out/bin/
    '';
  };

  # Custom GPD boot monitor compiled from source
  gpd-boot-monitor = pkgs.stdenv.mkDerivation {
    name = "gpd-boot-monitor";
    src = /home/a/nix-modules/src/gpd-tools;
    buildInputs = with pkgs; [ gcc ];
    buildPhase = ''
      gcc -o gpd-boot-monitor gpd-boot-monitor.c
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp gpd-boot-monitor $out/bin/
    '';
  };

  # Custom iio-hyprland rotation daemon for GPD Pocket 3
  gpd-iio-hyprland = pkgs.stdenv.mkDerivation {
    name = "gpd-iio-hyprland";
    src = /home/a/nix-modules/src/gpd-tools;
    buildInputs = with pkgs; [ gcc meson ninja pkg-config glib dbus ];
    buildPhase = ''
      meson setup build
      ninja -C build
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp build/iio-hyprland $out/bin/
    '';
  };

in
{
  # Comprehensive GPD Pocket 3 Hardware Integration
  # Custom compiled tools integrated into NixOS

  # Install all custom GPD tools
  environment.systemPackages = with pkgs; [
    gpd-hardware-control  # Custom thermal/fan/ambient light control
    gpd-boot-monitor      # Boot sequence analysis and optimization
    gpd-iio-hyprland      # Specialized auto-rotation daemon
  ];

  # GPD Hardware monitoring service
  systemd.user.services.gpd-hardware-monitor = {
    enable = true;
    description = "GPD Pocket 3 Comprehensive Hardware Monitor";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = pkgs.writeShellScript "gpd-hardware-monitor-reboot-safe" ''
        #!/usr/bin/env bash
        # REBOOT-SAFE: Dynamic system variable pattern
        sys="gcc coreutils"

        # Dynamically ensure hardware control is available
        if [ -x "${gpd-hardware-control}/bin/gpd-hardware-control" ]; then
          nix-shell -p $sys --run '${gpd-hardware-control}/bin/gpd-hardware-control --monitor'
        else
          echo "GPD hardware control tool not available"
          exit 1
        fi
      '';
      Restart = "always";
      RestartSec = "10";
      Type = "simple";
      # Enhanced restart policies and resource limits
      MemoryMax = "128M";
      CPUQuota = "30%";
      Environment = [
        "TERM=xterm-256color"
      ];
    };
  };

  # Enhanced GPD rotation service using custom daemon
  systemd.user.services.gpd-rotation-enhanced = {
    enable = true;
    description = "GPD Pocket 3 Enhanced Auto-Rotation";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = pkgs.writeShellScript "gpd-rotation-enhanced-reboot-safe" ''
        #!/usr/bin/env bash
        # REBOOT-SAFE: Dynamic system variable pattern
        sys="gcc meson ninja pkg-config glib dbus coreutils"

        # Dynamically ensure rotation daemon is available
        if [ -x "${gpd-iio-hyprland}/bin/iio-hyprland" ]; then
          nix-shell -p $sys --run '${gpd-iio-hyprland}/bin/iio-hyprland'
        else
          echo "GPD iio-hyprland tool not available"
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

  # Boot optimization service
  systemd.services.gpd-boot-analysis = {
    enable = true;
    description = "GPD Boot Sequence Analysis";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "gpd-boot-analysis-reboot-safe" ''
        #!/usr/bin/env bash
        # REBOOT-SAFE: Dynamic system variable pattern
        sys="gcc coreutils"

        # Dynamically ensure boot monitor is available
        if [ -x "${gpd-boot-monitor}/bin/gpd-boot-monitor" ]; then
          nix-shell -p $sys --run '${gpd-boot-monitor}/bin/gpd-boot-monitor --full-monitor'
        else
          echo "GPD boot monitor tool not available"
          exit 1
        fi
      '';
      # Enhanced restart policies and resource limits
      Restart = "on-failure";
      RestartSec = "30";
      MemoryMax = "64M";
      CPUQuota = "20%";
      Environment = [
        "TERM=xterm-256color"
      ];
    };
  };

  # GPD-specific kernel modules for hardware features
  boot.extraModulePackages = with config.boot.kernelPackages; [
    # Custom modules would go here if needed
  ];

  # Optimize for GPD Pocket 3 hardware characteristics
  hardware = {
    enableRedistributableFirmware = true;
    sensor.iio.enable = true;

    # OpenGL optimization for Intel UHD Graphics
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  # Environment variables for GPD tools
  environment.variables = {
    GPD_HARDWARE_CONTROL = "${gpd-hardware-control}/bin/gpd-hardware-control";
    GPD_BOOT_MONITOR = "${gpd-boot-monitor}/bin/gpd-boot-monitor";
    GPD_IIO_ROTATION = "${gpd-iio-hyprland}/bin/iio-hyprland";
  };

  # Create convenience commands for GPD management with reboot-safe patterns
  environment.shellAliases = {
    gpd-status = "nix-shell -p gcc --run '${gpd-hardware-control}/bin/gpd-hardware-control'";
    gpd-monitor = "nix-shell -p gcc --run '${gpd-hardware-control}/bin/gpd-hardware-control --monitor'";
    gpd-boot-check = "nix-shell -p gcc --run '${gpd-boot-monitor}/bin/gpd-boot-monitor'";
    gpd-rotation = "nix-shell -p gcc meson ninja pkg-config glib dbus --run '${gpd-iio-hyprland}/bin/iio-hyprland'";
  };
}