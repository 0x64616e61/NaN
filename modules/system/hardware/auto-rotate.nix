{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.hardware.autoRotate;
  
  # Enhanced auto-rotate script that handles multiple monitors
  auto-rotate-script = pkgs.writeShellScriptBin "auto-rotate-gpd" ''
    # Auto-rotate script for GPD Pocket 3 with Hyprland
    # Enhanced to support multiple monitors
    
    MONITOR="''${1:-${cfg.monitor}}"
    SCALE="''${2:-${toString cfg.scale}}"
    DEVICE="/sys/bus/iio/devices/iio:device0"
    LOCK_FILE="/tmp/rotation-lock-state"
    
    # Configuration for external monitors
    SYNC_EXTERNAL="false"  # Never sync external monitors - they should stay in normal orientation
    EXTERNAL_POSITION="${cfg.externalPosition}"
    
    # Check if rotation is locked
    check_lock() {
        if [ -f "$LOCK_FILE" ] && [ "$(cat $LOCK_FILE)" = "locked" ]; then
            return 0  # Locked
        fi
        return 1  # Unlocked
    }
    
    # Wait for accelerometer device to be available and properly initialized
    echo "Waiting for accelerometer device..."
    for i in {1..30}; do
        if [ -e "$DEVICE/name" ] && [ -e "$DEVICE/in_accel_x_raw" ]; then
            # Check if we can actually read valid values
            test_x=$(cat $DEVICE/in_accel_x_raw 2>/dev/null)
            test_y=$(cat $DEVICE/in_accel_y_raw 2>/dev/null)
            
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
    
    rotate_all_monitors() {
        local orientation=$1
        
        # Always rotate primary monitor
        echo "Rotating primary monitor $MONITOR to orientation: $orientation"
        ${pkgs.hyprland}/bin/hyprctl keyword monitor $MONITOR,preferred,auto,$SCALE,transform,$orientation
        
        # If external sync is enabled, rotate external monitors too
        if [ "$SYNC_EXTERNAL" = "true" ]; then
            # Get all connected monitors
            local all_monitors=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[].name')
            
            for mon in $all_monitors; do
                if [ "$mon" != "$MONITOR" ]; then
                    echo "Rotating external monitor $mon to orientation: $orientation"
                    
                    # Get monitor info
                    local mon_info=$(${pkgs.hyprland}/bin/hyprctl monitors -j | ${pkgs.jq}/bin/jq -r ".[] | select(.name==\"$mon\")")
                    local width=$(echo "$mon_info" | ${pkgs.jq}/bin/jq -r '.width')
                    local height=$(echo "$mon_info" | ${pkgs.jq}/bin/jq -r '.height')
                    local refresh=$(echo "$mon_info" | ${pkgs.jq}/bin/jq -r '.refreshRate' | cut -d. -f1)
                    
                    # Calculate position based on configuration
                    local position="auto"
                    case "$EXTERNAL_POSITION" in
                        "right")
                            position="1280x0"
                            ;;
                        "left") 
                            position="0x0"
                            ${pkgs.hyprland}/bin/hyprctl keyword monitor $MONITOR,preferred,2560x0,$SCALE,transform,$orientation
                            ;;
                        "above")
                            position="0x0"
                            ${pkgs.hyprland}/bin/hyprctl keyword monitor $MONITOR,preferred,0x1440,$SCALE,transform,$orientation
                            ;;
                        "below")
                            position="0x1920"
                            ;;
                    esac
                    
                    # Apply rotation to external monitor
                    ${pkgs.hyprland}/bin/hyprctl keyword monitor "$mon,''${width}x''${height}@''${refresh},$position,1,transform,$orientation"
                fi
            done
        fi
        
        # Rotate touch input
        rotate_touch $orientation
    }
    
    # Initialize with landscape orientation (3 = 270 degrees for GPD Pocket 3)
    echo "Forcing landscape orientation on service start (270 degrees)"
    rotate_all_monitors 3
    
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
        # Check if rotation is locked
        if check_lock; then
            echo "Rotation is locked, skipping..." >&2
            ${pkgs.coreutils}/bin/sleep 2
            continue
        fi
        
        orientation=$(get_orientation)
        
        if [ "$orientation" != "-1" ] && [ "$orientation" != "$last_orientation" ]; then
            echo "Rotating to orientation: $orientation"
            rotate_all_monitors $orientation
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
      example = "DSI-1";
      description = ''
        Monitor to rotate (check with: hyprctl monitors)
        Common values: eDP-1 (laptops), DSI-1 (GPD Pocket 3), HDMI-A-1
      '';
    };

    scale = mkOption {
      type = types.addCheck types.float (x: x >= 0.5 && x <= 3.0);
      default = 1.0;
      example = 1.5;
      description = ''
        Monitor scale to maintain during rotation (0.5-3.0)
        This value is preserved when the screen rotates
      '';
    };

    leftMaster = mkOption {
      type = types.bool;
      default = false;
      description = "Use left master layout in Hyprland";
    };

    syncExternal = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Synchronize rotation with external monitors
        WARNING: Most external monitors should stay in normal orientation
      '';
    };

    externalPosition = mkOption {
      type = types.enum [ "right" "left" "above" "below" ];
      default = "right";
      description = "Position of external monitor relative to primary";
    };
  };

  config = mkIf cfg.enable {
    # Validate configuration
    assertions = [
      {
        assertion = cfg.scale >= 0.5 && cfg.scale <= 3.0;
        message = "Auto-rotate scale must be between 0.5 and 3.0, got ${toString cfg.scale}";
      }
      {
        assertion = cfg.monitor != "";
        message = "Auto-rotate monitor name cannot be empty. Check available monitors with: hyprctl monitors";
      }
      {
        assertion = !config.custom.system.gpdPhysicalPositioning.autoRotation || !cfg.enable;
        message = ''
          Cannot enable both custom.system.hardware.autoRotate and custom.system.gpdPhysicalPositioning.autoRotation
          These modules provide similar functionality and will conflict.
          Choose one: hardware.autoRotate (recommended) or gpdPhysicalPositioning
        '';
      }
    ];
    # Install required packages
    environment.systemPackages = with pkgs; [
      iio-sensor-proxy  # Provides accelerometer data
      auto-rotate-script  # Enhanced auto-rotation script for GPD Pocket 3
      jq  # Required for parsing monitor info
    ];
    
    # Enable the iio-sensor-proxy service (even though we don't use it directly)
    hardware.sensor.iio.enable = true;
  };
}
