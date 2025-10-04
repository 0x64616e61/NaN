{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.hyprgrass;
in
{
  options.custom.hm.desktop.hyprgrass = {
    enable = mkEnableOption "Hyprgrass touchscreen gesture configuration";
    
    sensitivity = mkOption {
      type = types.float;
      default = 4.0;
      description = "Touch sensitivity (higher for touchscreens)";
    };
    
    workspaceSwipeFingers = mkOption {
      type = types.int;
      default = 3;
      description = "Number of fingers for workspace swipe";
    };
    
    longPressDelay = mkOption {
      type = types.int;
      default = 400;
      description = "Long press delay in milliseconds";
    };
  };

  config = mkIf cfg.enable {
    # Configure Hyprland to load the plugin (installed at system level)
    wayland.windowManager.hyprland.extraConfig = ''
      # Load hyprgrass plugin for touchscreen gestures
      plugin = ${pkgs.hyprlandPlugins.hyprgrass}/lib/libhyprgrass.so
      
      # Hyprgrass configuration for touchscreen
      plugin:touch_gestures {
        # Basic sensitivity settings
        sensitivity = ${toString cfg.sensitivity}
        workspace_swipe_fingers = ${toString cfg.workspaceSwipeFingers}
        long_press_delay = ${toString cfg.longPressDelay}
        
        # Hyprgrass specific settings
        hyprgrass {
          # Swipe gesture configuration
          swipe {
            workspace_swipe_fingers = ${toString cfg.workspaceSwipeFingers}
            edge_margin = 10
          }
          
          # Special gesture configuration
          special_gestures {
            # Enable all gesture types
            enable_swipe = true
            enable_pinch = true
            enable_edge_swipe = true
          }
        }
        
        # Experimental features (may help with detection)
        experimental {
          send_cancel = 1
        }
      }
      
      # Standard Hyprland gesture configuration for touchscreen
      gestures {
        workspace_swipe = true
        workspace_swipe_fingers = 3
        workspace_swipe_distance = 200
        workspace_swipe_invert = false
        workspace_swipe_min_speed_to_force = 30
        workspace_swipe_cancel_ratio = 0.5
        workspace_swipe_create_new = false
        workspace_swipe_direction_lock = true
        workspace_swipe_direction_lock_threshold = 10
        workspace_swipe_forever = false
      }
      
      # Touchscreen input configuration
      # Transform 3 = 270° rotation to match display orientation
      input {
        touchdevice {
          transform = 3
          output = DSI-1  # GPD Pocket 3 display
        }
      }
      
      # Simplified gesture bindings for debugging
      # Using Hyprland's native gesture events
      bind = , swipe:3:r, workspace, e-1
      bind = , swipe:3:l, workspace, e+1
      bind = , swipe:3:u, fullscreen, 1
      bind = , swipe:3:d, fullscreen, 0
      
      # Alternative: Try direct touch bindings
      bind = , touch, exec, echo "Touch detected" > /tmp/touch.log
    '';
  };
}