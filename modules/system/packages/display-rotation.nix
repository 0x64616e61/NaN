{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.packages.displayRotation;

  # Unified rotation control script with all functionality
  rotation-ctl = pkgs.writeScriptBin "rotation-ctl" ''
    #!${pkgs.bash}/bin/bash
    # Unified rotation control for GPD Pocket 3

    DEVICE="/sys/bus/iio/devices/iio:device0"
    THRESHOLD=500

    check_lock() {
        local display="$1"
        local lock_file="/tmp/rotation-lock-$display"
        if [ -f "$lock_file" ] && [ "$(cat $lock_file)" = "locked" ]; then
            return 0  # Locked
        fi
        return 1  # Unlocked
    }

    get_orientation() {
        local x=$(cat $DEVICE/in_accel_x_raw 2>/dev/null || echo 0)
        local y=$(cat $DEVICE/in_accel_y_raw 2>/dev/null || echo 0)

        if [ $x -gt $THRESHOLD ]; then
            echo "3"  # Landscape (270 degrees)
        elif [ $x -lt -$THRESHOLD ]; then
            echo "1"  # 90 degrees
        elif [ $y -gt $THRESHOLD ]; then
            echo "2"  # Inverted (180 degrees)
        elif [ $y -lt -$THRESHOLD ]; then
            echo "0"  # Portrait (normal)
        else
            echo "-1"  # No clear orientation
        fi
    }

    rotate_all() {
        local orientation=$1

        # External monitor needs different transform to match GPD visually
        local external_orientation=$orientation
        case $orientation in
            3) external_orientation=0 ;;  # GPD landscape -> External normal
            0) external_orientation=1 ;;  # GPD portrait -> External 90°
            1) external_orientation=2 ;;  # GPD 90° -> External 180°
            2) external_orientation=3 ;;  # GPD 180° -> External 270°
        esac

        # Rotate GPD display if not locked
        if ! check_lock "DSI-1"; then
            ${pkgs.hyprland}/bin/hyprctl keyword monitor DSI-1,1200x1920@60,0x0,1.5,transform,$orientation
            ${pkgs.hyprland}/bin/hyprctl keyword "device[gxtp7380:00-27c6:0113]:transform" $orientation
        fi

        # Rotate external display if connected and not locked
        if ${pkgs.hyprland}/bin/hyprctl monitors | grep -q "HDMI-A-1"; then
            if ! check_lock "HDMI-A-1"; then
                ${pkgs.hyprland}/bin/hyprctl keyword monitor HDMI-A-1,2560x1440@59,1280x0,1,transform,$external_orientation
            fi
        fi
    }

    cmd_service() {
        echo "Waiting for accelerometer device..."
        for i in {1..30}; do
            if [ -e "$DEVICE/name" ] && [ -e "$DEVICE/in_accel_x_raw" ]; then
                test_x=$(cat $DEVICE/in_accel_x_raw 2>/dev/null)
                test_y=$(cat $DEVICE/in_accel_y_raw 2>/dev/null)

                if [ -n "$test_x" ] && [ "$test_x" != "0" ] && [ -n "$test_y" ] && [ "$test_y" != "0" ]; then
                    echo "Accelerometer found: $(cat $DEVICE/name)"
                    break
                fi
            fi
            ${pkgs.coreutils}/bin/sleep 1
        done

        if [ ! -e "$DEVICE/in_accel_x_raw" ]; then
            echo "ERROR: Accelerometer not found"
            exit 1
        fi

        rotate_all 3
        last_orientation="3"
        ${pkgs.coreutils}/bin/sleep 5

        while true; do
            orientation=$(get_orientation)
            if [ "$orientation" != "-1" ] && [ "$orientation" != "$last_orientation" ]; then
                rotate_all $orientation
                last_orientation=$orientation
            fi
            ${pkgs.coreutils}/bin/sleep 0.5
        done
    }

    cmd_lock() {
        local display="''${1:-$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused == true) | .name')}"

        if [ -z "$display" ]; then
            echo "Error: Could not determine display"
            exit 1
        fi

        local lock_file="/tmp/rotation-lock-$display"
        if [ -f "$lock_file" ] && [ "$(cat $lock_file)" = "locked" ]; then
            echo "unlocked" > "$lock_file"
            echo "🔓 Rotation unlocked for $display"
        else
            echo "locked" > "$lock_file"
            echo "🔒 Rotation locked for $display"
        fi
        ${pkgs.procps}/bin/pkill -RTMIN+8 waybar 2>/dev/null || true
    }

    cmd_status() {
        local display="$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused == true) | .name')"
        local lock_file="/tmp/rotation-lock-$display"

        if [ -f "$lock_file" ] && [ "$(cat $lock_file)" = "locked" ]; then
            echo "🔒 $display"
        else
            echo "🔓 $display"
        fi
    }

    cmd_rotate() {
        case "''${1:-toggle}" in
            portrait|normal|0)
                rotate_all 0
                ;;
            landscape|270|3)
                rotate_all 3
                ;;
            inverted|180|2)
                rotate_all 2
                ;;
            90|1)
                rotate_all 1
                ;;
            toggle)
                current=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[0].transform')
                if [ "$current" = "3" ]; then
                    rotate_all 0
                else
                    rotate_all 3
                fi
                ;;
            *)
                echo "Usage: rotation-ctl rotate [portrait|landscape|inverted|90|toggle]"
                exit 1
                ;;
        esac
    }

    case "''${1:-help}" in
        service)
            cmd_service
            ;;
        lock)
            cmd_lock "''${2:-}"
            ;;
        status)
            cmd_status
            ;;
        rotate)
            cmd_rotate "''${2:-toggle}"
            ;;
        help|--help|-h)
            echo "Usage: rotation-ctl <command> [args]"
            echo ""
            echo "Commands:"
            echo "  service              Run auto-rotate service (daemon mode)"
            echo "  lock [display]       Toggle rotation lock for display"
            echo "  status               Show rotation lock status"
            echo "  rotate <orientation> Manually rotate displays"
            echo ""
            echo "Orientations: portrait|landscape|inverted|90|toggle"
            ;;
        *)
            echo "Unknown command: $1"
            echo "Run 'rotation-ctl help' for usage"
            exit 1
            ;;
    esac
  '';

  # Compatibility wrappers
  auto-rotate = pkgs.writeScriptBin "auto-rotate" ''
    #!${pkgs.bash}/bin/bash
    exec ${rotation-ctl}/bin/rotation-ctl service "$@"
  '';

  rotation-lock-toggle = pkgs.writeScriptBin "rotation-lock-toggle" ''
    #!${pkgs.bash}/bin/bash
    exec ${rotation-ctl}/bin/rotation-ctl lock "$@"
  '';

  rotation-lock-status = pkgs.writeScriptBin "rotation-lock-status" ''
    #!${pkgs.bash}/bin/bash
    exec ${rotation-ctl}/bin/rotation-ctl status "$@"
  '';

  rotation-lock-simple = pkgs.writeScriptBin "rotation-lock-simple" ''
    #!${pkgs.bash}/bin/bash
    exec ${rotation-ctl}/bin/rotation-ctl lock "$@"
  '';

  rotate-displays = pkgs.writeScriptBin "rotate-displays" ''
    #!${pkgs.bash}/bin/bash
    exec ${rotation-ctl}/bin/rotation-ctl rotate "$@"
  '';
in
{
  options.custom.system.packages.displayRotation = {
    enable = mkEnableOption "display rotation scripts for GPD Pocket 3";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      rotation-ctl
      auto-rotate
      rotate-displays
      rotation-lock-toggle
      rotation-lock-status
      rotation-lock-simple
    ];
  };
}
