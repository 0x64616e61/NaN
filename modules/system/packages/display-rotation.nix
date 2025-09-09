{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.packages.displayRotation;
  
  # Working auto-rotate script with proper transform mapping for external monitor
  auto-rotate-both = pkgs.writeScriptBin "auto-rotate-both" ''
    #!${pkgs.bash}/bin/bash
    # Auto-rotation for GPD Pocket 3 with synchronized external monitor
    
    DEVICE="/sys/bus/iio/devices/iio:device0"
    LOCK_FILE="/tmp/rotation-lock-state"
    THRESHOLD=500
    
    check_lock() {
        if [ -f "$LOCK_FILE" ] && [ "$(cat $LOCK_FILE)" = "locked" ]; then
            return 0  # Locked
        fi
        return 1  # Unlocked
    }
    
    echo "Waiting for accelerometer device..."
    for i in {1..30}; do
        if [ -e "$DEVICE/name" ] && [ -e "$DEVICE/in_accel_x_raw" ]; then
            test_x=$(cat $DEVICE/in_accel_x_raw 2>/dev/null)
            test_y=$(cat $DEVICE/in_accel_y_raw 2>/dev/null)
            
            if [ -n "$test_x" ] && [ "$test_x" != "0" ] && [ -n "$test_y" ] && [ "$test_y" != "0" ]; then
                echo "Accelerometer found: $(cat $DEVICE/name)"
                echo "Initial readings: X=$test_x Y=$test_y"
                break
            fi
        fi
        sleep 1
    done
    
    if [ ! -e "$DEVICE/in_accel_x_raw" ]; then
        echo "ERROR: Accelerometer not found"
        exit 1
    fi
    
    echo "Starting auto-rotation for both displays..."
    
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
        echo "Rotating to orientation: $orientation"
        
        # External monitor needs different transform to match GPD visually
        local external_orientation=$orientation
        case $orientation in
            3) external_orientation=0 ;;  # GPD landscape -> External normal
            0) external_orientation=1 ;;  # GPD portrait -> External 90°
            1) external_orientation=2 ;;  # GPD 90° -> External 180°
            2) external_orientation=3 ;;  # GPD 180° -> External 270°
        esac
        
        # Rotate displays
        ${pkgs.hyprland}/bin/hyprctl keyword monitor DSI-1,1200x1920@60,0x0,1.5,transform,$orientation
        ${pkgs.hyprland}/bin/hyprctl keyword monitor HDMI-A-1,2560x1440@59,1280x0,1,transform,$external_orientation
        ${pkgs.hyprland}/bin/hyprctl keyword "device[gxtp7380:00-27c6:0113]:transform" $orientation
    }
    
    # Force landscape on start
    echo "Setting initial landscape orientation..."
    rotate_all 3
    last_orientation="3"
    
    sleep 5
    
    # Main loop
    while true; do
        if check_lock; then
            sleep 2
            continue
        fi
        
        orientation=$(get_orientation)
        
        if [ "$orientation" != "-1" ] && [ "$orientation" != "$last_orientation" ]; then
            rotate_all $orientation
            last_orientation=$orientation
        fi
        
        sleep 0.5
    done
  '';
  
  # Manual rotation control script
  # Toggle rotation lock script
  rotation-lock-toggle = pkgs.writeScriptBin "rotation-lock-toggle" ''
    #!${pkgs.bash}/bin/bash
    LOCK_FILE="/tmp/rotation-lock-state"
    
    if [ -f "$LOCK_FILE" ] && [ "$(cat $LOCK_FILE)" = "locked" ]; then
        echo "unlocked" > "$LOCK_FILE"
        echo "Rotation unlocked"
        
        # Restart auto-rotate service if it's running
        if systemctl --user is-active auto-rotate-both.service >/dev/null 2>&1; then
            systemctl --user restart auto-rotate-both.service
        fi
    else
        echo "locked" > "$LOCK_FILE"
        echo "Rotation locked"
    fi
  '';
  
  rotate-displays = pkgs.writeScriptBin "rotate-displays" ''
    #!${pkgs.bash}/bin/bash
    # Manual display rotation control script
    
    case "''${1:-toggle}" in
        portrait|normal|0)
            echo "Rotating both displays to portrait (normal)..."
            ${pkgs.hyprland}/bin/hyprctl keyword monitor DSI-1,1200x1920@60,0x0,1.5,transform,0
            ${pkgs.hyprland}/bin/hyprctl keyword monitor HDMI-A-1,2560x1440@59,1280x0,1,transform,1
            ;;
        landscape|270|3)
            echo "Rotating both displays to landscape (270 degrees)..."
            ${pkgs.hyprland}/bin/hyprctl keyword monitor DSI-1,1200x1920@60,0x0,1.5,transform,3
            ${pkgs.hyprland}/bin/hyprctl keyword monitor HDMI-A-1,2560x1440@59,1280x0,1,transform,0
            ;;
        inverted|180|2)
            echo "Rotating both displays to inverted (180 degrees)..."
            ${pkgs.hyprland}/bin/hyprctl keyword monitor DSI-1,1200x1920@60,0x0,1.5,transform,2
            ${pkgs.hyprland}/bin/hyprctl keyword monitor HDMI-A-1,2560x1440@59,1280x0,1,transform,3
            ;;
        90|1)
            echo "Rotating both displays to 90 degrees..."
            ${pkgs.hyprland}/bin/hyprctl keyword monitor DSI-1,1200x1920@60,0x0,1.5,transform,1
            ${pkgs.hyprland}/bin/hyprctl keyword monitor HDMI-A-1,2560x1440@59,1280x0,1,transform,2
            ;;
        toggle)
            # Get current rotation
            current=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[0].transform')
            if [ "$current" = "3" ]; then
                $0 portrait
            else
                $0 landscape
            fi
            ;;
        *)
            echo "Usage: $0 [portrait|landscape|inverted|90|toggle]"
            exit 1
            ;;
    esac
  '';
in
{
  options.custom.system.packages.displayRotation = {
    enable = mkEnableOption "display rotation scripts for GPD Pocket 3";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      auto-rotate-both
      rotate-displays
      rotation-lock-toggle
    ];
  };
}
