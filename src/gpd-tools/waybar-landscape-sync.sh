#!/usr/bin/env bash
# Waybar Landscape Mode Synchronization for GPD Pocket 3
# Maintains waybar at top position regardless of rotation for consistent landscape UX

CONFIG_FILE="/home/a/.config/waybar/config.jsonc"

sync_waybar_landscape() {
    local current_transform=$(hyprctl monitors | grep -A15 DSI-1 | grep transform | awk '{print $2}' 2>/dev/null || echo "3")

    echo "🔄 Syncing waybar for landscape mode (transform: $current_transform)"

    # ALWAYS maintain top position for landscape UX regardless of device orientation
    # This provides consistent interface experience
    sed -i 's/"layer": "[^"]*"/"layer": "top"/g; s/"position": "[^"]*"/"position": "top"/g' "$CONFIG_FILE"

    # Only restart waybar if position actually changed
    local current_position=$(grep -o '"position": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4)
    if [ "$current_position" != "top" ]; then
        echo "  🔄 Restarting waybar to apply landscape positioning"
        pkill waybar
        sleep 0.5
        waybar &
    fi

    echo "✅ Waybar landscape positioning maintained"
}

# Main monitoring loop
echo "🎯 Starting waybar landscape synchronization service"
echo "Maintains top position for consistent landscape UX"

# Apply initial landscape positioning
sync_waybar_landscape

# Monitor for changes and maintain landscape positioning
while true; do
    # Check every 3 seconds for position changes
    sleep 3

    # Only sync if waybar is running
    if pgrep waybar > /dev/null; then
        current_config_position=$(grep -o '"position": "[^"]*"' "$CONFIG_FILE" | cut -d'"' -f4 2>/dev/null || echo "unknown")

        # If position changed from top, restore it
        if [ "$current_config_position" != "top" ]; then
            echo "$(date): Detected waybar position change to '$current_config_position', restoring landscape mode"
            sync_waybar_landscape
        fi
    else
        # Waybar not running, restart it with correct config
        echo "$(date): Waybar not running, restarting with landscape configuration"
        sync_waybar_landscape
    fi
done