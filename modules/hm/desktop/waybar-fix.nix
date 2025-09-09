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
    
    # Override the hyde.conf to uncomment the waybar startup
    home.file.".config/hypr/hyde.conf".text = mkForce ''
      #!      ░▒▒▒░░░▓▓           ___________
      #!    ░░▒▒▒░░░░░▓▓        //___________/
      #!   ░░▒▒▒░░░░░▓▓     _   _ _    _ _____
      #!   ░░▒▒░░░░░▓▓▓▓▓▓ | | | | |  | |  __/
      #!    ░▒▒░░░░▓▓   ▓▓ | |_| | |_/ /| |___
      #!     ░▒▒░░▓▓   ▓▓   \__  |____/ |____/
      #!       ░▒▓▓   ▓▓  //____/

      # Use this for reference to override the default HyDE' hyprland configuration

      # ! Never source ~/.config/hypr/hyde.conf directly, it is sourced by the main configuration file
      # This file acts as an override configuration for the user to set their environment variables and startup commands
      # Static variable declaration in hyde.conf will be prioritized over the default and dynamic configuration

      #  NOTE 
      # Leaving the variable empty will unset the variable
      # Commenting out the variable will use the default value
      # For updated configuration options, see https://github.com/HyDE-Project/HyDE/blob/master/Configs/.config/hypr/hyde.conf
      # For simplicity, ./hyde.conf ONLY accepts $ for variables and # for comments, will sanitize the file to remove any other characters
      # $start.VAR , $env.VAR are ONLY HyDE specific conventions for consistency.

      # Keyboard modifier
      # $mainMod = SUPER # windows key


      # ▄▀█ █▀█ █▀█ █▀
      # █▀█ █▀▀ █▀▀ ▄█

      # $QUICKAPPS = # used for quick app launcher
      # $BROWSER = firefox # default browser, if commented out , will use the default browser
      # $EDITOR = code # default editor, if commented out , will use the default editor
      # $EXPLORER= dolphin # default file manager, if commented out , will use the default file manager
$TERMINAL = ghostty # default terminal, changed from kitty to ghostty
      # $LOCKSCREEN=hyprlock # default lockscreen, you can use any lockscreen you want, eg swaylock
      # $IDLE=hypridle # default idle manager, you can use any idle manager you want,eg swayidle


      # // █░░ ▄▀█ █░█ █▄░█ █▀▀ █░█
      # // █▄▄ █▀█ █▄█ █░▀█ █▄▄ █▀█
      # See https://wiki.hyprland.org/Configuring/Keywords/
      # Override the default startup commands

      # $start.XDG_PORTAL_RESET=$scrPath/resetxdgportal.sh
      # $start.DBUS_SHARE_PICKER=dbus-update-activation-environment --systemd --all                                              # for XDPH
      # $start.SYSTEMD_SHARE_PICKER=systemctl --user import-environment QT_QPA_PLATFORMTHEME WAYLAND_DISPLAY XDG_CURRENT_DESKTOP # for XDPH
      $start.BAR=waybar
      # $start.NOTIFICATIONS=swaync # dunst
      # $start.APPTRAY_BLUETOOTH=blueman-applet
      # $start.WALLPAPER=$scrPath/swwwallpaper.sh
      # $start.TEXT_CLIPBOARD=wl-paste --type text --watch cliphist store
      # $start.IMAGE_CLIPBOARD=wl-paste --type image --watch cliphist store
      # $start.BATTERY_NOTIFY=$scrPath/batterynotify.sh
      # $start.NETWORK_MANAGER=nm-applet --indicator
      # $start.REMOVABLE_MEDIA=udiskie --no-automount --smart-tray
      # $start.AUTH_DIALOGUE=$scrPath/polkitkdeauth.sh
      # $start.IDLE_DAEMON=$IDLE

      # // █▀▀ █▄░█ █░█
      # // ██▄ █░▀█ ▀▄▀

      # See https://wiki.hyprland.org/Configuring/Environment-variables/
      # Override the default environment variables


      # # Toolkit Backend Variables - https://wiki.hyprland.org/Configuring/Environment-variables/#toolkit-backend-variables
      # $env.GDK_BACKEND = wayland,x11,* #s GTK: Use wayland if available. If not: try x11, then any other GDK backend.
      # # $env.QT_QPA_PLATFORM = wayland;xcb #Qt: Use wayland if available, fall back to x11 if not.
      # $env.SDL_VIDEODRIVER = wayland #s Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
      # $env.CLUTTER_BACKEND = wayland #s Clutter package already has wayland enabled, this variable will force Clutter applications to try and use the Wayland backend

      # # XDG Specifications - https://wiki.hyprland.org/Configuring/Environment-variables/#xdg-specifications
      # $env.XDG_CURRENT_DESKTOP = Hyprland
      # $env.XDG_SESSION_TYPE = wayland
      # $env.XDG_SESSION_DESKTOP = Hyprland

      # # Qt Variables  - https://wiki.hyprland.org/Configuring/Environment-variables/#qt-variables

      # $env.QT_AUTO_SCREEN_SCALE_FACTOR = 1 # (From the Qt documentation) enables automatic scaling, based on the monitor's pixel density
      # $env.QT_QPA_PLATFORM=wayland;xcb # Tell Qt applications to use the Wayland backend, and fall back to x11 if Wayland is unavailable
      # $env.QT_WAYLAND_DISABLE_WINDOWDECORATION = 1 # Disables window decorations on Qt applications
      # $env.QT_QPA_PLATFORMTHEME = qt6ct            # Tells Qt based applications to pick your theme from qt5ct, use with Kvantum.

      # # HyDE Environment Variables -

      # $env.PATH =
      # $env.MOZ_ENABLE_WAYLAND=1              # Enable Wayland for Firefox
      # $env.GDK_SCALE=1                       # Set GDK scale to 1 // For Xwayland on HiDPI
      # $env.ELECTRON_OZONE_PLATFORM_HINT=auto # Set Electron Ozone Platform Hint to auto // For Electron apps on Wayland

      # #  XDG-DIRS

      # $env.XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR
      # $env.XDG_CONFIG_HOME=$HOME/.config
      # $env.XDG_CACHE_HOME=$HOME/.cache
      # $env.XDG_DATA_HOME=$HOME/.local/share



      # These variable will override the default and the theme configuration
      # Do not uncomment the variables if you want HyDE to do the theme configuration for you

      # // █▀▀ ▀█▀ █▄▀
      # // █▄█ ░█░ █░█


      #$GTK_THEME=Wallbash-Gtk
      #$ICON_THEME=Tela-circle-dracula
      #$COLOR_SCHEME=prefer-dark

      # // █▀▀ █░█ █▀█ █▀ █▀█ █▀█
      # // █▄▄ █▄█ █▀▄ ▄█ █▄█ █▀▄

      #$CURSOR_THEME=Bibata-Modern-Ice
      #$CURSOR_SIZE=24

      # // █▀▀ █▀█ █▄░█ ▀█▀
      # // █▀░ █▄█ █░▀█ ░█░

      #$FONT=Canterell
      #$FONT_SIZE=10
      #$DOCUMENT_FONT=Cantarell
      #$DOCUMENT_FONT_SIZE=10
      #$MONOSPACE_FONT=CaskaydiaCove Nerd Font Mono
      #$MONOSPACE_FONT_SIZE=9
      #$FONT_ANTIALIASING=rgba
      #$FONT_HINTING=full


      #  // █░░ █▀█ █▀▀ █▄▀ █▀ █▀▀ █▀█ █▀▀ █▀▀ █▄░█
      #  // █▄▄ █▄█ █▄▄ █░█ ▄█ █▄▄ █▀▄ ██▄ ██▄ █░▀█

      #Setting the Hyprlock layout will override any layout set in the ./hypr/hyprlock.sh
      # Dynamic Hyprlock layout should be set in the ./hypr/hyprlock.sh file
      # $LAYOUT_PATH=/path/to/hyprlock/layout.conf
    '';
  };
}