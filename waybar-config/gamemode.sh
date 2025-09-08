#!/usr/bin/env bash
# Modified gamemode script - starts with gamemode enabled by default
HYPRGAMEMODE=$(hyprctl getoption animations:enabled | sed -n '1p' | awk '{print $2}')

# Check if this is first run (create flag file for persistence)
GAMEMODE_STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/hyde-gamemode-state"

# Initialize gamemode as ON by default if no state file exists
if [ ! -f "$GAMEMODE_STATE_FILE" ]; then
    echo "0" > "$GAMEMODE_STATE_FILE"  # 0 = gamemode ON (animations disabled)
fi

STORED_STATE=$(cat "$GAMEMODE_STATE_FILE")

# Hyprland performance toggle
if [ "$HYPRGAMEMODE" = 1 ]; then
        # Turn ON gamemode (disable animations)
        hyprctl -q --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:xray 1;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0 ;\
        keyword decoration:active_opacity 1 ;\
        keyword decoration:inactive_opacity 1 ;\
        keyword decoration:fullscreen_opacity 1 ;\
        keyword layerrule noanim,waybar ;\
        keyword layerrule noanim,swaync-notification-window ;\
        keyword layerrule noanim,swww-daemon ;\
        keyword layerrule noanim,rofi
        "
        hyprctl 'keyword windowrule opaque,class:(.*)' # ensure all windows are opaque
        echo "0" > "$GAMEMODE_STATE_FILE"  # Save state
        exit
else
        # Turn OFF gamemode (enable animations)
        hyprctl reload config-only -q
        echo "1" > "$GAMEMODE_STATE_FILE"  # Save state
fi