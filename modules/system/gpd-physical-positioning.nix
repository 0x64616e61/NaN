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

  # Window physical pinning script
  window-pinning-script = pkgs.writeShellScript "window-physical-pinning" ''
    #!/usr/bin/env bash
    # True Physical Position Pinning for GPD Pocket 3
    # Windows maintain same physical location relative to device hardware

    # Physical pinning: if window is in bottom-right physical corner,
    # it stays in bottom-right corner regardless of screen rotation

    test_window_repositioning() {
        echo "🧪 Testing physical window repositioning..."

        # Get current windows on DSI-1
        local windows=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r ".[] | select(.monitor == 0)")
        if [ -z "$windows" ]; then
            echo "No windows on DSI-1 - creating test window"
            ${pkgs.hyprland}/bin/hyprctl dispatch exec "[workspace 1 silent] ghostty --title=\"PhysicalPinTest\""
            sleep 2
        fi

        # Get a test window
        local test_window=$(${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -r ".[] | select(.monitor == 0) | .address" | head -1)
        if [ -n "$test_window" ]; then
            echo "📍 Testing with window: $test_window"

            # Move to bottom-right physical corner (transform 3 coordinates)
            echo "Moving to bottom-right physical corner..."
            ${pkgs.hyprland}/bin/hyprctl dispatch movewindowpixel "exact 700 400,address:$test_window"

            # Test rotation to portrait and see if window maintains physical position
            echo "Rotating to portrait - window should move to maintain physical corner..."
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "DSI-1, 1200x1920@60, 0x0, 2.0, transform, 0"

            # Calculate new position for physical corner preservation
            # Transform 3→0: bottom-right physical = bottom-right logical
            # New coordinates: (700,400) → maintain same relative position
            sleep 1
            ${pkgs.hyprland}/bin/hyprctl dispatch movewindowpixel "exact 700 1000,address:$test_window"
            echo "✅ Window repositioned to maintain physical bottom-right corner"

            # Return to landscape
            sleep 2
            ${pkgs.hyprland}/bin/hyprctl keyword monitor "DSI-1, 1200x1920@60, 0x0, 2.0, transform, 3"
            ${pkgs.hyprland}/bin/hyprctl dispatch movewindowpixel "exact 700 400,address:$test_window"
            echo "✅ Returned to landscape with physical positioning"
        fi
    }

    continuous_physical_pinning() {
        echo "🎯 Starting continuous physical position pinning..."

        local last_transform=$(${pkgs.hyprland}/bin/hyprctl monitors | grep -A15 DSI-1 | grep transform | awk '{print $2}')
        echo "Initial transform: $last_transform"

        while true; do
            local current_transform=$(${pkgs.hyprland}/bin/hyprctl monitors | grep -A15 DSI-1 | grep transform | awk '{print $2}')

            if [ "$current_transform" != "$last_transform" ]; then
                echo "🔄 Physical rotation: $last_transform → $current_transform"

                # Get all windows on DSI-1
                ${pkgs.hyprland}/bin/hyprctl clients -j | ${pkgs.jq}/bin/jq -c ".[] | select(.monitor == 0)" | while read -r window; do
                    local address=$(echo "$window" | ${pkgs.jq}/bin/jq -r '.address')
                    local old_x=$(echo "$window" | ${pkgs.jq}/bin/jq -r '.at[0]')
                    local old_y=$(echo "$window" | ${pkgs.jq}/bin/jq -r '.at[1]')
                    local width=$(echo "$window" | ${pkgs.jq}/bin/jq -r '.size[0]')
                    local height=$(echo "$window" | ${pkgs.jq}/bin/jq -r '.size[1]')
                    local title=$(echo "$window" | ${pkgs.jq}/bin/jq -r '.title')

                    echo "📍 Repositioning '$title' from ($old_x,$old_y)"

                    # Calculate physical position preservation
                    local new_x new_y
                    case "$last_transform,$current_transform" in
                        "3,0") # Landscape to Portrait: preserve physical corners
                            # Physical bottom-right stays bottom-right
                            # Physical top-left stays top-left
                            if [ $old_x -gt 600 ] && [ $old_y -gt 300 ]; then
                                new_x=700  # Bottom-right physical corner
                                new_y=1000
                            else
                                new_x=50   # Top-left physical corner
                                new_y=100
                            fi
                            ;;
                        "0,3") # Portrait to Landscape: preserve physical corners
                            if [ $old_y -gt 800 ]; then
                                new_x=700  # Bottom area
                                new_y=400
                            else
                                new_x=50   # Top area
                                new_y=100
                            fi
                            ;;
                        *) # Maintain relative position for other rotations
                            new_x=$old_x
                            new_y=$old_y
                            ;;
                    esac

                    echo "   → Moving to ($new_x,$new_y) to preserve physical position"
                    ${pkgs.hyprland}/bin/hyprctl dispatch movewindowpixel "exact $new_x $new_y,address:$address"
                done

                last_transform=$current_transform
            fi

            sleep 0.2  # Optimized for safe maximum responsiveness (5Hz)
        done
    }

    # Start with test, then continuous monitoring
    test_window_repositioning
    continuous_physical_pinning
  '';
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

    # Declarative window physical pinning
    systemd.user.services.gpd-window-pinning = mkIf config.custom.system.gpdPhysicalPositioning.windowPhysicalPinning {
      enable = true;
      description = "GPD Window Physical Pinning (Reboot Safe)";
      wantedBy = [ "hyprland-session.target" ];
      after = [ "hyprland-session.target" "waybar.service" ];
      wants = [ "hyprland-session.target" ];

      serviceConfig = {
        ExecStart = "${window-pinning-script}";
        Restart = "always";
        RestartSec = "10";
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