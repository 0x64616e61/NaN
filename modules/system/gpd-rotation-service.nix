{ config, lib, pkgs, ... }:

with lib;

{
  # Persistent GPD Pocket 3 Auto-Rotation Service
  systemd.user.services.gpd-iio-rotation = {
    enable = true;
    description = "GPD Pocket 3 Auto-Rotation via iio-hyprland";
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = pkgs.writeShellScript "gpd-iio-rotation-reboot-safe" ''
        #!/usr/bin/env bash
        # REBOOT-SAFE: Dynamic system variable pattern
        sys="gcc meson ninja pkg-config glib dbus coreutils"

        # Build iio-hyprland tool dynamically
        BUILD_DIR="/tmp/gpd-iio-build-$$"
        mkdir -p "$BUILD_DIR"
        cd "$BUILD_DIR"

        # Copy source and build
        cp -r /home/a/nix-modules/src/gpd-tools/* .
        nix-shell -p $sys --run 'meson setup build && ninja -C build'

        # Run the tool
        if [ -f "build/iio-hyprland" ]; then
          ./build/iio-hyprland
        else
          echo "Failed to build iio-hyprland tool"
          exit 1
        fi

        # Cleanup
        cd /tmp
        rm -rf "$BUILD_DIR"
      '';
      Restart = "always";
      RestartSec = "5";
      Type = "simple";
      # Resource limits
      MemoryMax = "256M";
      CPUQuota = "50%";
      # Environment variables
      Environment = [
        "TERM=xterm-256color"
        "WAYLAND_DISPLAY=wayland-1"
      ];
    };
  };

  # Install iio-hyprland binary permanently
  environment.systemPackages = with pkgs; [
    (pkgs.stdenv.mkDerivation {
      name = "iio-hyprland-gpd";
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
    })
  ];
}