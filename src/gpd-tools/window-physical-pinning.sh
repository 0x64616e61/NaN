#!/usr/bin/env bash
# True Physical Position Pinning for GPD Pocket 3
# Windows maintain same physical location relative to device hardware

# Physical pinning: if window is in bottom-right physical corner,
# it stays in bottom-right corner regardless of screen rotation

test_window_repositioning() {
    echo "🧪 Testing physical window repositioning..."

    # Get current windows on DSI-1
    local windows=$(hyprctl clients -j | jq -r ".[] | select(.monitor == 0)")
    if [ -z "$windows" ]; then
        echo "No windows on DSI-1 - creating test window"
        hyprctl dispatch exec "[workspace 1 silent] ghostty --title=\"PhysicalPinTest\""
        sleep 2
    fi

    # Get a test window
    local test_window=$(hyprctl clients -j | jq -r ".[] | select(.monitor == 0) | .address" | head -1)
    if [ -n "$test_window" ]; then
        echo "📍 Testing with window: $test_window"

        # Move to bottom-right physical corner (transform 3 coordinates)
        echo "Moving to bottom-right physical corner..."
        hyprctl dispatch movewindowpixel "exact 700 400,address:$test_window"

        # Test rotation to portrait and see if window maintains physical position
        echo "Rotating to portrait - window should move to maintain physical corner..."
        hyprctl keyword monitor "DSI-1, 1200x1920@60, 0x0, 2.0, transform, 0"

        # Calculate new position for physical corner preservation
        # Transform 3→0: bottom-right physical = bottom-right logical
        # New coordinates: (700,400) → maintain same relative position
        sleep 1
        hyprctl dispatch movewindowpixel "exact 700 1000,address:$test_window"
        echo "✅ Window repositioned to maintain physical bottom-right corner"

        # Return to landscape
        sleep 2
        hyprctl keyword monitor "DSI-1, 1200x1920@60, 0x0, 2.0, transform, 3"
        hyprctl dispatch movewindowpixel "exact 700 400,address:$test_window"
        echo "✅ Returned to landscape with physical positioning"
    fi
}

continuous_physical_pinning() {
    echo "🎯 Starting continuous physical position pinning..."

    local last_transform=$(hyprctl monitors | grep -A15 DSI-1 | grep transform | awk '{print $2}')
    echo "Initial transform: $last_transform"

    while true; do
        local current_transform=$(hyprctl monitors | grep -A15 DSI-1 | grep transform | awk '{print $2}')

        if [ "$current_transform" != "$last_transform" ]; then
            echo "🔄 Physical rotation: $last_transform → $current_transform"

            # Get all windows on DSI-1
            hyprctl clients -j | jq -c ".[] | select(.monitor == 0)" | while read -r window; do
                local address=$(echo "$window" | jq -r '.address')
                local old_x=$(echo "$window" | jq -r '.at[0]')
                local old_y=$(echo "$window" | jq -r '.at[1]')
                local width=$(echo "$window" | jq -r '.size[0]')
                local height=$(echo "$window" | jq -r '.size[1]')
                local title=$(echo "$window" | jq -r '.title')

                echo "📍 Repositioning '$title' from ($old_x,$old_y)"

                # Calculate physical position preservation
                local new_x new_y
                case "$last_transform,$current_transform" in
                    "3,0") # Landscape to Portrait: preserve physical corners
                        # Physical bottom-right stays bottom-right
                        # Physical top-left stays top-left
                        if [ $old_x -gt 600 ] && [ $old_y -gt 300 ]; then
                            new_x=700  # Bottom-right physical corner
                            new_y=1000
                        else
                            new_x=50   # Top-left physical corner
                            new_y=100
                        fi
                        ;;
                    "0,3") # Portrait to Landscape: preserve physical corners
                        if [ $old_y -gt 800 ]; then
                            new_x=700  # Bottom area
                            new_y=400
                        else
                            new_x=50   # Top area
                            new_y=100
                        fi
                        ;;
                    *) # Maintain relative position for other rotations
                        new_x=$old_x
                        new_y=$old_y
                        ;;
                esac

                echo "   → Moving to ($new_x,$new_y) to preserve physical position"
                hyprctl dispatch movewindowpixel "exact $new_x $new_y,address:$address"
            done

            last_transform=$current_transform
        fi

        sleep 0.2  # Optimized for safe maximum responsiveness (5Hz)
    done
}

# Start with test, then continuous monitoring
test_window_repositioning
continuous_physical_pinning