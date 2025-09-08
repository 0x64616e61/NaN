{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.gestures;
in
{
  options.custom.hm.desktop.gestures = {
    enable = mkEnableOption "touchpad gestures for workspace switching";
    
    swipeFingers = mkOption {
      type = types.int;
      default = 3;
      description = "Number of fingers for swipe gestures (touchpad only)";
    };
  };

  config = mkIf cfg.enable {
    # Create a custom gesture configuration file that will be sourced by Hyprland
    home.file.".config/hypr/custom-gestures.conf".text = ''
      # Custom gesture configuration for GPD Pocket 3
      
      # Touchpad gestures for workspace switching
      gestures {
        workspace_swipe = true
        workspace_swipe_fingers = ${toString cfg.swipeFingers}
        workspace_swipe_distance = 300
        workspace_swipe_invert = false  # Natural direction: swipe left = next, right = previous
        workspace_swipe_min_speed_to_force = 30
        workspace_swipe_cancel_ratio = 0.5
        workspace_swipe_create_new = false
        workspace_swipe_direction_lock = true
        workspace_swipe_direction_lock_threshold = 10
        workspace_swipe_forever = false
        workspace_swipe_use_r = false
      }
      
      # Touchpad configuration
      input {
        touchpad {
          natural_scroll = true
          tap-to-click = true
          drag_lock = false
          disable_while_typing = true
          scroll_factor = 1.0
          clickfinger_behavior = true
          tap-and-drag = true
          middle_button_emulation = false
        }
      }
    '';
    
    # Append a source line to userprefs.conf to include our custom gestures
    home.file.".config/hypr/userprefs.conf".text = ''
      # User preferences - sourced by Hyprland
      source = ./custom-gestures.conf
      source = ./gestures-fix.conf
    '';
  };
}