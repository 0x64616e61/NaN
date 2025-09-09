{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.hardware.autoRotateMulti;
  
  # Enhanced auto-rotate script that handles multiple monitors
  auto-rotate-multi-script = pkgs.writeShellScriptBin "auto-rotate-multi" ''
    # Auto-rotate script for GPD Pocket 3 with multi-monitor support
    # Synchronizes rotation across all connected displays
    
    PRIMARY_MONITOR="''${1:-${cfg.primaryMonitor}}"
    SCALE="''${2:-${toString cfg.scale}}"
    # Format primary scale for hyprctl
    SCALE=$(echo "$SCALE" | sed 's/\.0*$//')
    DEVICE="/sys/bus/iio/devices/iio:device0"
    LOCK_FILE="/tmp/rotation-lock-state"
    
    # Check if rotation is locked
    check_lock() {
        if [ -f "$LOCK_FILE" ] && [ "$(cat $LOCK_FILE)" = "locked" ]; then
            return 0  # Locked
        fi
        return 1  # Unlocked
    }
    
    # Wait for accelerometer device
    echo "Waiting for accelerometer device..."
    for i in {1..30}; do
        if [ -e "$DEVICE/name" ] && [ -e "$DEVICE/in_accel_x_raw" ]; then
            test_x=$(cat $DEVICE/in_accel_x_raw 2>/dev/null)
            test_y=$(cat $DEVICE/in_accel_y_raw 2>/dev/null)
            
            if [ -n "$test_x" ] && [ "$test_x" != "0" ] && [ -n "$test_y" ] && [ "$test_y" != "0" ]; then
                echo "Accelerometer device found: $(cat $DEVICE/name)"
                echo "Initial readings: X=$test_x Y=$test_y"
                break
            fi
        fi
        ${pkgs.coreutils}/bin/sleep 1
    done
    
    if [ ! -e "$DEVICE/in_accel_x_raw" ]; then
        echo "ERROR: Accelerometer not found, exiting"
        exit 1
    fi
    
    echo "Waiting for accelerometer to stabilize..."
    ${pkgs.coreutils}/bin/sleep 3
    
    echo "Starting multi-monitor auto-rotate"
    
    THRESHOLD=500
    
    get_orientation() {
        local x=$(cat $DEVICE/in_accel_x_raw 2>/dev/null || echo 0)
        local y=$(cat $DEVICE/in_accel_y_raw 2>/dev/null || echo 0)
        local z=$(cat $DEVICE/in_accel_z_raw 2>/dev/null || echo 0)
        
        echo "Accelerometer: X=$x, Y=$y, Z=$z" >&2
        
        if [ $x -gt $THRESHOLD ]; then
            echo "3"  # 270 degrees - landscape
        elif [ $x -lt -$THRESHOLD ]; then
            echo "1"  # 90 degrees
        elif [ $y -gt $THRESHOLD ]; then
            echo "2"  # 180 degrees
        elif [ $y -lt -$THRESHOLD ]; then
            echo "0"  # Normal
        else
            echo "-1"  # No clear orientation
        fi
    }
    
    rotate_touch() {
        local orientation=$1
        local touch_device="gxtp7380:00-27c6:0113"
        
        echo "Rotating touch to orientation: $orientation"
        ${pkgs.hyprland}/bin/hyprctl keyword "device[$touch_device]:transform" $orientation
    }
    
    rotate_all_monitors() {
        local orientation=$1
        
        # Get all connected monitors
        local monitors=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[].name')
        
        echo "Rotating all monitors to orientation: $orientation"
        
        for monitor in $monitors; do
            echo "  Rotating $monitor"
            
            # Get current monitor settings
            local monitor_info=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r ".[] | select(.name==\"$monitor\")")
            local width=$(echo "$monitor_info" | ${pkgs.jq}/bin/jq -r '.width')
            local height=$(echo "$monitor_info" | ${pkgs.jq}/bin/jq -r '.height')
            local refresh=$(echo "$monitor_info" | ${pkgs.jq}/bin/jq -r '.refreshRate')
            # Format refresh rate to integer
            refresh=$(echo "$refresh" | cut -d. -f1)
            
            # Use monitor-specific scale or default
            local monitor_scale=$SCALE
            if [ "$monitor" = "HDMI-A-1" ] && [ "${toString cfg.externalScale}" != "0" ]; then
                monitor_scale="${toString cfg.externalScale}"
            fi
            
            # Format scale for hyprctl (remove decimal if it's .0)
            monitor_scale=$(echo "$monitor_scale" | sed 's/\.0*$//')
            
            # Calculate position based on primary monitor and orientation
            local position="auto"
            if [ "$monitor" = "$PRIMARY_MONITOR" ]; then
                position="0x0"
            elif [ "$monitor" = "HDMI-A-1" ]; then
                # Position external monitor based on orientation and sync mode
                case "${cfg.externalPosition}" in
                    "right")
                        if [ "$orientation" = "0" ] || [ "$orientation" = "2" ]; then
                            # Portrait mode: position to the right
                            position="1200,0"
                        else
                            # Landscape mode: position to the right
                            position="1280,0"
                        fi
                        ;;
                    "left")
                        position="0,0"
                        # Adjust primary monitor position
                        ${pkgs.hyprland}/bin/hyprctl keyword monitor $PRIMARY_MONITOR,preferred,2560x0,$SCALE,transform,$orientation
                        ;;
                    "above")
                        position="0,0"
                        ${pkgs.hyprland}/bin/hyprctl keyword monitor $PRIMARY_MONITOR,preferred,0x1440,$SCALE,transform,$orientation
                        ;;
                    "below")
                        position="0,1920"
                        ;;
                    *)
                        position="auto"
                        ;;
                esac
            fi
            
            # Apply rotation with sync mode consideration
            if [ "${if cfg.syncRotation then "true" else "false"}" = "true" ] || [ "$monitor" = "$PRIMARY_MONITOR" ]; then
                ${pkgs.hyprland}/bin/hyprctl keyword monitor ""$monitor,$width"x"$height"@"$refresh",$position,$monitor_scale,transform,$orientation"
            elif [ "${toString cfg.externalRotation}" != "-1" ]; then
                # Use fixed rotation for external monitor
                ${pkgs.hyprland}/bin/hyprctl keyword monitor ""$monitor,$width"x"$height"@"$refresh",$position,$monitor_scale,transform,${toString cfg.externalRotation}"
            else
                # Keep external monitor at normal orientation
                ${pkgs.hyprland}/bin/hyprctl keyword monitor ""$monitor,$width"x"$height"@"$refresh",$position,$monitor_scale,transform,0"
            fi
        done
    }
    
    # Initialize with landscape orientation
    echo "Forcing landscape orientation on start"
    rotate_all_monitors 3
    rotate_touch 3
    
    last_orientation="3"
    
    echo "Waiting before monitoring orientation..."
    ${pkgs.coreutils}/bin/sleep 10
    
    # Read actual orientation
    current_orientation=$(get_orientation)
    if [ "$current_orientation" != "-1" ]; then
        echo "Current orientation: $current_orientation"
        last_orientation=$current_orientation
    fi
    
    echo "Starting orientation monitoring..."
    
    while true; do
        # Check if rotation is locked
        if check_lock; then
            echo "Rotation is locked, skipping..."
            ${pkgs.coreutils}/bin/sleep 2
            continue
        fi
        
        orientation=$(get_orientation)
        
        if [ "$orientation" != "-1" ] && [ "$orientation" != "$last_orientation" ]; then
            echo "Detected orientation change: $last_orientation -> $orientation"
            rotate_all_monitors $orientation
            rotate_touch $orientation
            last_orientation=$orientation
        fi
        
        ${pkgs.coreutils}/bin/sleep 0.5
    done
  '';
in
{
  options.custom.system.hardware.autoRotateMulti = {
    enable = mkEnableOption "multi-monitor auto-rotation synchronized with accelerometer";
    
    primaryMonitor = mkOption {
      type = types.str;
      default = "DSI-1";
      description = "Primary monitor (GPD Pocket 3 built-in display)";
    };
    
    scale = mkOption {
      type = types.float;
      default = 1.5;
      description = "Scale for primary monitor";
    };
    
    externalScale = mkOption {
      type = types.float;
      default = 1.0;
      description = "Scale for external monitors";
    };
    
    syncRotation = mkOption {
      type = types.bool;
      default = true;
      description = "Sync rotation of external monitors with primary";
    };
    
    externalPosition = mkOption {
      type = types.enum [ "right" "left" "above" "below" "auto" ];
      default = "right";
      description = "Position of external monitor relative to primary";
    };
    
    externalRotation = mkOption {
      type = types.int;
      default = -1;
      description = "Fixed rotation for external monitor (-1 for sync, 0-3 for fixed)";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      iio-sensor-proxy
      auto-rotate-multi-script
      jq  # Required for JSON parsing in the script
    ];
    
    hardware.sensor.iio.enable = true;
    
    # Disable the single-monitor auto-rotate if multi is enabled
    custom.system.hardware.autoRotate.enable = mkForce false;
  };
}
