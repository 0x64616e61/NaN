#!/usr/bin/env bash
# GPD Pocket 3 Window Physical Position Pinning
# Keeps windows in same physical location during rotation

WINDOW_STATE_FILE="/home/a/.config/gpd-window-positions"

save_window_layout() {
    local transform=$1
    echo "💾 Saving window layout for transform $transform"

    # Get all windows on DSI-1
    hyprctl clients -j | jq -r ".[] | select(.monitor == \"DSI-1\") | {address, title, at, size, class}" > "$WINDOW_STATE_FILE.transform$transform"

    echo "Saved $(jq length < "$WINDOW_STATE_FILE.transform$transform") windows for transform $transform"
}

restore_window_layout() {
    local new_transform=$1
    local old_transform=$2

    echo "🔄 Restoring windows from transform $old_transform to $new_transform"

    if [ ! -f "$WINDOW_STATE_FILE.transform$old_transform" ]; then
        echo "No saved layout for transform $old_transform"
        return
    fi

    # Read saved window positions and apply physical space mapping
    while read -r window; do
        local address=$(echo "$window" | jq -r '.address')
        local old_x=$(echo "$window" | jq -r '.at[0]')
        local old_y=$(echo "$window" | jq -r '.at[1]')
        local width=$(echo "$window" | jq -r '.size[0]')
        local height=$(echo "$window" | jq -r '.size[1]')

        # Calculate new position based on physical space preservation
        local new_x new_y
        case "$old_transform,$new_transform" in
            "3,0") # Landscape to Portrait
                new_x=$old_y
                new_y=$((1200 - old_x - width))
                ;;
            "0,3") # Portrait to Landscape
                new_x=$((1920 - old_y - height))
                new_y=$old_x
                ;;
            "3,2") # Landscape to Inverted
                new_x=$((1200 - old_x - width))
                new_y=$((1920 - old_y - height))
                ;;
            *) # Default: maintain position
                new_x=$old_x
                new_y=$old_y
                ;;
        esac

        echo "Moving window $address from ($old_x,$old_y) to ($new_x,$new_y)"
        hyprctl dispatch movewindowpixel "exact $new_x $new_y,address:$address"

    done < <(jq -c '.[]' "$WINDOW_STATE_FILE.transform$old_transform" 2>/dev/null)
}

# Monitor for transform changes and handle window repositioning
last_transform=$(hyprctl monitors | grep -A15 DSI-1 | grep transform | awk '{print $2}')
echo "🎯 Starting window pinning monitor (initial transform: $last_transform)"

save_window_layout $last_transform

while true; do
    current_transform=$(hyprctl monitors | grep -A15 DSI-1 | grep transform | awk '{print $2}')

    if [ "$current_transform" != "$last_transform" ]; then
        echo "🔄 Transform changed: $last_transform → $current_transform"

        # Save current layout before applying new positions
        save_window_layout $last_transform

        # Restore windows to physical positions
        restore_window_layout $current_transform $last_transform

        last_transform=$current_transform
    fi

    sleep 0.3
done