{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.hardware.autoRotate;
  
  # Custom auto-rotate script for MXC4005 accelerometer (GPD Pocket 3)
  auto-rotate-script = pkgs.writeShellScriptBin "auto-rotate-gpd" ''
    # Auto-rotate script for GPD Pocket 3 with Hyprland
    # Uses raw accelerometer values from MXC4005
    
    MONITOR="''${1:-${cfg.monitor}}"
    SCALE="''${2:-${toString cfg.scale}}"
    DEVICE="/sys/bus/iio/devices/iio:device0"
    
    # Wait for accelerometer device to be available and properly initialized
    echo "Waiting for accelerometer device..."
    for i in {1..30}; do
        if [ -e "$DEVICE/name" ] && [ -e "$DEVICE/in_accel_x_raw" ]; then
            # Check if we can actually read valid values
            local test_x=$(cat $DEVICE/in_accel_x_raw 2>/dev/null)
            local test_y=$(cat $DEVICE/in_accel_y_raw 2>/dev/null)
            
            if [ -n "$test_x" ] && [ "$test_x" != "0" ] && [ -n "$test_y" ] && [ "$test_y" != "0" ]; then
                echo "Accelerometer device found and initialized: $(cat $DEVICE/name)"
                echo "Initial readings: X=$test_x Y=$test_y"
                break
            else
                echo "Accelerometer found but not ready yet... ($i/30)"
            fi
        else
            echo "Waiting for accelerometer... ($i/30)"
        fi
        ${pkgs.coreutils}/bin/sleep 1
    done
    
    if [ ! -e "$DEVICE/in_accel_x_raw" ]; then
        echo "ERROR: Accelerometer not found after 30 seconds, exiting"
        exit 1
    fi
    
    # Give device extra time to stabilize after detection
    echo "Waiting for accelerometer to stabilize..."
    ${pkgs.coreutils}/bin/sleep 3
    
    echo "Starting auto-rotate for monitor $MONITOR"
    
    # Thresholds for orientation detection
    THRESHOLD=500
    
    get_orientation() {
        local x=$(cat $DEVICE/in_accel_x_raw 2>/dev/null || echo 0)
        local y=$(cat $DEVICE/in_accel_y_raw 2>/dev/null || echo 0)
        local z=$(cat $DEVICE/in_accel_z_raw 2>/dev/null || echo 0)
        
        # Debug logging
        echo "Accelerometer readings: X=$x, Y=$y, Z=$z" >&2
        
        # Determine orientation based on which axis has the strongest reading
        if [ $x -gt $THRESHOLD ]; then
            echo "3"  # Right-up (270 degrees) - landscape
        elif [ $x -lt -$THRESHOLD ]; then
            echo "1"  # Left-up (90 degrees)
        elif [ $y -gt $THRESHOLD ]; then
            echo "2"  # Upside-down (180 degrees)
        elif [ $y -lt -$THRESHOLD ]; then
            echo "0"  # Normal (portrait)
        else
            echo "-1"  # No clear orientation
        fi
    }
    
    rotate_touch() {
        local orientation=$1
        local touch_device="gxtp7380:00-27c6:0113"
        
        # Map orientation to touch transform using correct syntax
        echo "Rotating touch to orientation: $orientation"
        ${pkgs.hyprland}/bin/hyprctl keyword "device[$touch_device]:transform" $orientation
    }
    
    # Initialize with landscape orientation (3 = 270 degrees for GPD Pocket 3)
    # This ensures we always start in landscape mode regardless of device position
    # Force landscape on every service start/restart
    echo "Forcing landscape orientation on service start (270 degrees)"
    ${pkgs.hyprland}/bin/hyprctl keyword monitor $MONITOR,preferred,auto,$SCALE,transform,3
    rotate_touch 3
    
    # Set initial orientation to landscape, ignore actual sensor reading
    last_orientation="3"
    
    # Wait longer before starting orientation monitoring to avoid immediate rotation
    echo "Staying in landscape for 10 seconds before monitoring orientation..."
    ${pkgs.coreutils}/bin/sleep 10
    
    # Read the actual orientation now to prevent immediate switch
    current_orientation=$(get_orientation)
    if [ "$current_orientation" != "-1" ]; then
        echo "Current actual orientation is: $current_orientation"
        last_orientation=$current_orientation
    else
        echo "Could not read orientation, keeping landscape"
        last_orientation="3"
    fi
    
    echo "Starting orientation monitoring..."
    
    while true; do
        orientation=$(get_orientation)
        
        if [ "$orientation" != "-1" ] && [ "$orientation" != "$last_orientation" ]; then
            echo "Rotating to orientation: $orientation"
            ${pkgs.hyprland}/bin/hyprctl keyword monitor $MONITOR,preferred,auto,$SCALE,transform,$orientation
            rotate_touch $orientation
            last_orientation=$orientation
        fi
        
        ${pkgs.coreutils}/bin/sleep 0.5
    done
  '';
in
{
  options.custom.system.hardware.autoRotate = {
    enable = mkEnableOption "automatic screen rotation for convertible devices";
    
    monitor = mkOption {
      type = types.str;
      default = "eDP-1";
      description = "Monitor to rotate (check with hyprctl monitors)";
    };
    
    scale = mkOption {
      type = types.float;
      default = 1.0;
      description = "Monitor scale to maintain during rotation";
    };
    
    leftMaster = mkOption {
      type = types.bool;
      default = false;
      description = "Use left master layout";
    };
  };

  config = mkIf cfg.enable {
    # Install required packages
    environment.systemPackages = with pkgs; [
      iio-sensor-proxy  # Provides accelerometer data
      auto-rotate-script  # Custom auto-rotation script for GPD Pocket 3
    ];
    
    # Enable the iio-sensor-proxy service (even though we don't use it directly)
    hardware.sensor.iio.enable = true;
  };
}