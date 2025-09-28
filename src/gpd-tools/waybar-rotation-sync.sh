#!/usr/bin/env bash
# Waybar Display-Pinned Positioning for GPD Pocket 3
# Keeps waybar on the same physical edge during rotation

get_transform() {
    nix-shell -p hyprland gawk gnugrep --run 'hyprctl monitors | grep -A15 DSI-1 | grep transform | awk \'\'{print $2}\'\'\''
}

update_waybar_position() {
    local transform=$1
    local config_file="/home/a/.config/waybar/config.jsonc"

    # Kill waybar to restart with new position
    nix-shell -p procps --run 'pkill waybar'

    # PHYSICAL EDGE PINNING: Waybar stays on physical bottom edge of device
    case $transform in
        0) # Portrait (0°) - physical bottom = logical bottom
            nix-shell -p gnused --run 'sed -i '\''s/"layer": "[^"]*"/"layer": "bottom"/g'\'' "$config_file"'
            ;;
        1) # Landscape left (90°) - physical bottom = logical right
            nix-shell -p gnused --run 'sed -i '\''s/"layer": "[^"]*"/"layer": "right"/g'\'' "$config_file"'
            ;;
        2) # Portrait inverted (180°) - physical bottom = logical top
            nix-shell -p gnused --run 'sed -i '\''s/"layer": "[^"]*"/"layer": "top"/g'\'' "$config_file"'
            ;;
        3) # Landscape right (270°) - physical bottom = logical LEFT
            nix-shell -p gnused --run 'sed -i '\''s/"layer": "[^"]*"/"layer": "left"/g'\'' "$config_file"'
            ;;
    esac

    # Restart waybar with new position
    nix-shell -p waybar --run 'waybar &'
    nix-shell -p coreutils --run 'echo "Waybar repositioned for transform $transform"'
}

# Monitor for transform changes
current_transform=$(get_transform)
nix-shell -p coreutils --run 'echo "Initial transform: $current_transform"'
update_waybar_position $current_transform

# Monitor for changes
while true; do
    new_transform=$(get_transform)
    if [ "$new_transform" != "$current_transform" ]; then
        nix-shell -p coreutils --run 'echo "Transform changed: $current_transform -> $new_transform"'
        update_waybar_position $new_transform
        current_transform=$new_transform
    fi
    nix-shell -p coreutils --run 'sleep 0.2'  # Check every 200ms for responsiveness
done