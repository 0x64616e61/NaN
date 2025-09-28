#!/usr/bin/env bash
# UX-Compliant Waybar for GPD Pocket 3
# Works with HyDE system while ensuring proper physical positioning

echo "🎯 Starting UX-Compliant GPD Waybar System"

# Create UX-compliant configuration that overrides HyDE
create_ux_compliant_config() {
    local transform=$1
    local config_file="/home/a/.config/waybar/config.jsonc"

    # Backup original HyDE config
    cp "$config_file" "${config_file}.hyde-backup" 2>/dev/null || true

    # Create UX-compliant configuration
    cat > "$config_file" << EOF
{
    "layer": "$(get_physical_layer $transform)",
    "output": ["DSI-1"],
    "position": "$(get_physical_layer $transform)",
    "height": 32,
    "width": 200,
    "exclusive": true,
    "passthrough": false,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["battery", "tray"],
    "hyprland/workspaces": {
        "format": "{icon}",
        "format-icons": {
            "1": "1",
            "2": "2",
            "3": "3"
        }
    },
    "clock": {
        "format": "{:%H:%M}",
        "tooltip-format": "{:%Y-%m-%d %H:%M:%S}"
    },
    "battery": {
        "format": "{capacity}%",
        "format-charging": "⚡{capacity}%"
    },
    "tray": {
        "spacing": 5
    }
}
EOF

    echo "✅ UX-compliant config created for transform $transform"
}

get_physical_layer() {
    local transform=$1
    case $transform in
        0) echo "bottom" ;;  # Portrait: physical bottom = logical bottom
        1) echo "right" ;;   # 90°: physical bottom = logical right
        2) echo "top" ;;     # 180°: physical bottom = logical top
        3) echo "left" ;;    # 270°: physical bottom = logical left
        *) echo "bottom" ;;
    esac
}

# Monitor and apply UX compliance continuously
last_transform=-1

while true; do
    current_transform=$(hyprctl monitors | grep -A15 DSI-1 | grep transform | awk '{print $2}')

    if [ "$current_transform" != "$last_transform" ]; then
        echo "🔄 UX Compliance: Transform $last_transform → $current_transform"

        # Kill HyDE waybar management temporarily
        pkill -f "waybar.py" 2>/dev/null || true
        pkill waybar 2>/dev/null || true

        # Apply UX-compliant configuration
        create_ux_compliant_config $current_transform

        # Start UX-compliant waybar
        sleep 1
        waybar &

        echo "✅ UX-compliant waybar active on physical edge"
        last_transform=$current_transform
    fi

    sleep 1
done