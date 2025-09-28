#!/usr/bin/env nix-shell
#! nix-shell -i bash -p hyprland coreutils

# Simple GPD Pocket 3 Auto-Rotation Script
# Monitors accelerometer and rotates display accordingly

DEVICE="/sys/bus/iio/devices/iio:device0"
THRESHOLD=700
MONITOR="DSI-1"

echo "🔄 Starting GPD Pocket 3 auto-rotation..."
echo "Monitor: $MONITOR | Threshold: $THRESHOLD"

# Function to get orientation
get_orientation() {
    local x=$(cat "$DEVICE/in_accel_x_raw" 2>/dev/null || echo "0")
    local y=$(cat "$DEVICE/in_accel_y_raw" 2>/dev/null || echo "0")

    # Determine orientation based on accelerometer values
    if [ "${x#-}" -gt "$THRESHOLD" ]; then
        if [ "$x" -gt 0 ]; then
            echo "1"  # 90° right
        else
            echo "3"  # 270° left (current landscape)
        fi
    elif [ "${y#-}" -gt "$THRESHOLD" ]; then
        if [ "$y" -gt 0 ]; then
            echo "2"  # 180° upside down
        else
            echo "0"  # 0° normal portrait
        fi
    else
        echo "3"  # Default to current landscape
    fi
}

# Function to apply rotation
apply_rotation() {
    local transform="$1"
    echo "Applying transform: $transform"
    hyprctl keyword monitor "$MONITOR,1200x1920@60,0x0,2.00,transform,$transform" 2>/dev/null || true
}

# Main loop
last_transform="3"  # Start with current landscape

while true; do
    current_transform=$(get_orientation)

    if [ "$current_transform" != "$last_transform" ]; then
        echo "$(date): Orientation changed to transform $current_transform"
        apply_rotation "$current_transform"
        last_transform="$current_transform"
    fi

    sleep 2
done