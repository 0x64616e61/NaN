#!/usr/bin/env bash
# Fixed Waybar Physical Positioning Service for GPD Pocket 3

CONFIG_FILE="/home/a/.config/waybar/config.jsonc"

update_waybar_for_transform() {
    local transform=$1

    echo "🔄 Updating waybar for transform $transform"

    # FIXED: Always keep waybar at top for landscape preference
    # Regardless of rotation, maintain top position for consistent UX
    echo "  Maintaining landscape waybar position (top) for transform $transform"
    sed -i 's/"layer": "[^"]*"/"layer": "top"/g; s/"position": "[^"]*"/"position": "top"/g' "$CONFIG_FILE"

    # Restart waybar to apply changes
    pkill waybar
    sleep 0.5
    waybar &
    echo "✅ Waybar repositioned for transform $transform"
}

# Monitor transform changes
last_transform=$(hyprctl monitors | grep -A15 DSI-1 | grep transform | awk '{print $2}')
echo "🎯 Starting fixed waybar positioning service (initial transform: $last_transform)"

# Apply initial positioning
update_waybar_for_transform $last_transform

while true; do
    current_transform=$(hyprctl monitors | grep -A15 DSI-1 | grep transform | awk '{print $2}')

    if [ "$current_transform" != "$last_transform" ]; then
        echo "Transform changed: $last_transform → $current_transform"
        update_waybar_for_transform $current_transform
        last_transform=$current_transform
    fi

    sleep 0.5
done