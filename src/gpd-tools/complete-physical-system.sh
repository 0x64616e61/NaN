#!/usr/bin/env bash
# Complete Physical Positioning System for GPD Pocket 3
# Actually moves windows AND waybar during auto-rotation

echo "🎯 Starting Complete Physical Positioning System"

last_transform=-1

while true; do
    current_transform=$(hyprctl monitors | grep -A15 DSI-1 | grep transform | awk '{print $2}')

    if [ "$current_transform" != "$last_transform" ] && [ "$current_transform" != "" ]; then
        echo "🔄 Auto-rotation detected: $last_transform → $current_transform"

        # 1. MOVE WAYBAR TO CORRECT PHYSICAL EDGE
        case $current_transform in
            0) edge="bottom" ;;  # Portrait
            1) edge="right" ;;   # 90° left
            2) edge="top" ;;     # 180°
            3) edge="left" ;;    # 270° landscape
        esac

        echo "📍 Moving waybar to physical edge: $edge"
        sed -i "s/\"layer\": \"[^\"]*\"/\"layer\": \"$edge\"/g" /home/a/.config/waybar/config.jsonc
        sed -i "s/\"position\": \"[^\"]*\"/\"position\": \"$edge\"/g" /home/a/.config/waybar/config.jsonc
        pkill waybar
        waybar &

        # 2. MOVE ALL WINDOWS TO PRESERVE PHYSICAL POSITIONS
        echo "🪟 Repositioning windows for physical preservation..."
        hyprctl clients -j | jq -c ".[] | select(.monitor == 0)" | while read -r window; do
            address=$(echo "$window" | jq -r '.address')
            old_x=$(echo "$window" | jq -r '.at[0]')
            old_y=$(echo "$window" | jq -r '.at[1]')
            title=$(echo "$window" | jq -r '.title')

            # Calculate new position based on rotation
            case "$last_transform,$current_transform" in
                "3,0"|"0,3") # Landscape ↔ Portrait
                    if [ $old_x -gt 480 ]; then
                        new_x=600; new_y=800  # Right side → bottom area
                    else
                        new_x=100; new_y=100  # Left side → top area
                    fi
                    ;;
                *) # Other rotations - maintain general area
                    new_x=$old_x; new_y=$old_y
                    ;;
            esac

            echo "   📍 '$title': ($old_x,$old_y) → ($new_x,$new_y)"
            hyprctl dispatch movewindowpixel "exact $new_x $new_y,address:$address"
        done

        last_transform=$current_transform
        echo "✅ Physical positioning complete for transform $current_transform"
    fi

    sleep 0.5
done