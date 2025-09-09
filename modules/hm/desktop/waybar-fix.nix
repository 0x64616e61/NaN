{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.waybarFix;
in
{
  options.custom.hm.desktop.waybarFix = {
    enable = mkEnableOption "waybar startup fix for HyDE with custom transparent theme";
  };

  config = mkIf cfg.enable {
    # Use home-manager activation script to force apply our customizations
    # This runs after every rebuild and ensures our CSS is applied
    home.activation.waybarCustomization = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Applying custom waybar configuration..."
      
      # Create the waybar styles directory if it doesn't exist
      mkdir -p $HOME/.local/share/waybar/styles
      
      # Write our custom CSS directly
      cat > $HOME/.local/share/waybar/styles/hyprdots.css << 'WAYBAR_EOF'
/* Group Styles */

/* Pill Styles */
@import "groups/pill.css";
@import "groups/pill-up.css";
@import "groups/pill-right.css";
@import "groups/pill-down.css";
@import "groups/pill-left.css";
@import "groups/pill-in.css";
@import "groups/pill-out.css";
/* Leaf Style */
@import "groups/leaf.css";
@import "groups/leaf-inverse.css";


/* Dynamic Stuff */
/*
"../../../" Use relative path to navigate $HOME $HOME/
*/
@import "../../../../.config/waybar/includes/border-radius.css";
@import "../../../../.config/waybar/includes/global.css";

/* Base HyDE Styles */

window#waybar {
    background: @bar-bg;
    font-size: 12px;
    min-height: 0;
}

* {
    min-height: 0;
    margin: 0;
    padding: 0;
}

/* Spread modules evenly within pill groups */
#pill-right box,
#pill-left box {
    padding: 0 15px;
}

/* Better spacing for center pill modules */
#pill-center box {
    padding: 0 20px;
}

/* Extra spacing between center modules */
#pill-center > box > * {
    margin-left: 0.5em;
    margin-right: 0.5em;
}

#pill-right,
#pill-left,
#pill-center {
    padding: 0;
}

/* Extra spacing for temperature/sensors module */
#custom-sensorsinfo {
    padding-left: 2em;
    padding-right: 2em;
    margin-left: 1em;
    margin-right: 1em;
}

/* Tighter spacing for other right-side modules */
#pill-right > box > *,
#pill-right1 > box > *,
#pill-right2 > box > * {
    margin-left: 0.3em;
    margin-right: 0.3em;
}

/* Ensure proper spacing for left modules too */
#pill-left > box > *,
#pill-left1 > box > *,
#pill-left2 > box > * {
    margin-left: 0.4em;
    margin-right: 0.4em;
}

/* Game mode icon specific styling */
#custom-gamemode {
    padding-left: 0.6em;
    padding-right: 0.6em;
    margin-left: 0.4em;
    margin-right: 0.4em;
    color: #ffffff;
    font-size: 13px;
}

/*
 These are groups/islands configs

*/
#leaf,
#leaf-inverse,
#leaf-up,
#leaf-down,
#leaf-right,
#leaf-left,
#pill,
#pill-right,
#pill-left,
#pill-down,
#pill-up,
#pill-in,
#pill-out {
    background-color: transparent;
    border-style: solid;
    border-color: transparent;
    padding-left: 0em;
    padding-right: 0em;
    padding-top: 0em;
    padding-bottom: 0em;
    margin: 0;
}




#workspaces button {
    box-shadow: none;
    text-shadow: none;
    padding: 0em;
    margin-top: 0.15em;
    margin-bottom: 0.15em;
    margin-left: 0.1em;
    margin-right: 0.1em;
    padding-left: 0.2em;
    padding-right: 0.2em;
    color: #ffffff; /* Catppuccin Macchiato Teal */
    font-size: 11px;
    min-width: 1.2em;
    min-height: 1.2em;
    animation: ws_normal 20s ease-in-out 1;
}

#workspaces button.active {
    background: #ffffff; /* Teal background for active */
    color: #181825; /* Catppuccin Macchiato Base (dark) */
    margin-left: 0.15em;
    margin-right: 0.15em;
    padding-left: 0.3em;
    padding-right: 0.3em;
    border-radius: 2px;
    min-width: 1.2em;
    min-height: 1.2em;
    animation: ws_active 20s ease-in-out 1;
    transition: all 0.4s cubic-bezier(.55, -0.68, .48, 1.682);
}

#workspaces button:hover {
    background: rgba(255, 255, 255, 0.2); /* Teal with transparency */
    color: #ffffff;
    animation: ws_hover 20s ease-in-out 1;
    transition: all 0.3s cubic-bezier(.55, -0.68, .48, 1.682);
}

#taskbar button {
    box-shadow: none;
    text-shadow: none;
    padding: 0em;
    margin-top: 0.3em;
    margin-bottom: 0.3em;
    margin-left: 0em;
    padding-left: 0.3em;
    padding-right: 0.3em;
    margin-right: 0em;
    color: #ffffff; /* Catppuccin Macchiato Teal */
    animation: tb_normal 20s ease-in-out 1;
}

/* Fix icon spacing - add proper margins to modules */
/* Catppuccin Macchiato Teal: #ffffff */
#clock,
#battery,
#cpu,
#memory,
#disk,
#temperature,
#backlight,
#network,
#pulseaudio,
#wireplumber,
#custom-media,
#tray,
#mode,
#idle_inhibitor,
#scratchpad,
#power-profiles-daemon,
#mpd {
    padding-left: 0.5em;
    padding-right: 0.5em;
    margin-left: 0.2em;
    margin-right: 0.2em;
    font-size: 11px;
    min-width: 1.4em;
    color: #ffffff;
}

/* System tray specific spacing */
#tray > .passive {
    margin-left: 0.3em;
    margin-right: 0.3em;
}

#tray > .active {
    margin-left: 0.3em;
    margin-right: 0.3em;
}

/* Apply Catppuccin Macchiato Teal to all custom modules */
/* Reduce spacing for right-side modules to prevent crowding */
#custom-wallpaper,
#custom-screenshot,
#custom-exit,
#custom-lock,
#custom-reboot,
#custom-power,
#custom-hyprsunset,
#custom-gamemode,
#custom-hint,
#custom-spotify,
#custom-weather,
#custom-updater,
#custom-media,
#custom-launcher {
    color: #ffffff;
    padding-left: 0.4em;
    padding-right: 0.4em;
    margin-left: 0.15em;
    margin-right: 0.15em;
    font-size: 11px;
    min-width: 1.2em;
}

/* Force all module labels and values to be teal */
.module label {
    color: #ffffff;
}

.module {
    color: #ffffff;
}

/* Ensure all text in modules is teal */
#clock label,
#battery label,
#cpu label,
#memory label,
#disk label,
#temperature label,
#backlight label,
#network label,
#pulseaudio label,
#wireplumber label {
    color: #ffffff;
}

/* Tray icons */
#tray {
    color: #ffffff;
}

#tray * {
    color: #ffffff;
}

/* Global override for any remaining elements */
tooltip {
    background: #181825;
    border: 1px solid #ffffff;
    color: #ffffff;
}

tooltip label {
    color: #ffffff;
}

/* Force teal on all text elements */
label {
    color: #ffffff;
}

/* Accent colors for highlights and borders */
*:hover {
    border-color: #ffffff;
}

*:focus {
    border-color: #ffffff;
}

/* Progress bars and sliders */
progressbar {
    background-color: rgba(255, 255, 255, 0.2);
}

progressbar trough {
    background-color: rgba(255, 255, 255, 0.1);
}

progressbar progress {
    background-color: #ffffff;
}

/* Hover states for all modules */
#clock:hover,
#battery:hover,
#cpu:hover,
#memory:hover,
#disk:hover,
#temperature:hover,
#backlight:hover,
#network:hover,
#pulseaudio:hover {
    background-color: rgba(255, 255, 255, 0.1);
    color: #ffffff;
}

/* Active/pressed states */
*:active {
    color: #ffffff;
}

/* Ensure icons are teal */
.fa, .fas, .far, .fab {
    color: #ffffff;
}
WAYBAR_EOF
      
      echo "Custom waybar CSS applied to ~/.local/share/waybar/styles/hyprdots.css"
      
      # Enable game mode by default (disable animations for performance)
      echo "Enabling game mode..."
      # Wait for Hyprland to be ready
      sleep 3
      
      # Force game mode ON by disabling animations and effects
      if command -v hyprctl >/dev/null 2>&1; then
        hyprctl -q --batch "\
        keyword animations:enabled 0;\
        keyword decoration:shadow:enabled 0;\
        keyword decoration:blur:xray 1;\
        keyword decoration:blur:enabled 0;\
        keyword general:gaps_in 0;\
        keyword general:gaps_out 0;\
        keyword general:border_size 1;\
        keyword decoration:rounding 0;\
        keyword decoration:active_opacity 1;\
        keyword decoration:inactive_opacity 1;\
        keyword decoration:fullscreen_opacity 1;\
        keyword layerrule noanim,waybar;\
        keyword layerrule noanim,swaync-notification-window;\
        keyword layerrule noanim,swww-daemon;\
        keyword layerrule noanim,rofi
        " > /dev/null 2>&1 || true
        
        hyprctl 'keyword windowrule opaque,class:(.*)' > /dev/null 2>&1 || true
        
        # Save state for the gamemode script
        mkdir -p "$HOME/.cache"
        echo "0" > "$HOME/.cache/hyde-gamemode-state"
        
        echo "Game mode enabled (animations disabled for performance)"
      else
        echo "hyprctl not found, skipping game mode activation"
      fi
    '';
    
  };
}