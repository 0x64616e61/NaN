{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.displayManagement;
  
  # Rotation lock toggle script
  rotation-lock-toggle = pkgs.writeShellScriptBin "rotation-lock-toggle" ''
    LOCK_FILE="/tmp/rotation-lock-state"
    
    # Toggle lock state
    if [ -f "$LOCK_FILE" ] && [ "$(cat $LOCK_FILE)" = "locked" ]; then
        echo "unlocked" > "$LOCK_FILE"
        echo "Rotation unlocked"
        # Signal waybar to update
        pkill -RTMIN+20 waybar 2>/dev/null || true
    else
        echo "locked" > "$LOCK_FILE"
        echo "Rotation locked"
        # Signal waybar to update
        pkill -RTMIN+20 waybar 2>/dev/null || true
    fi
  '';
  
  # Rotation lock status script
  rotation-lock-status = pkgs.writeShellScriptBin "rotation-lock-status" ''
    LOCK_FILE="/tmp/rotation-lock-state"
    
    if [ -f "$LOCK_FILE" ] && [ "$(cat $LOCK_FILE)" = "locked" ]; then
        echo '{"text":" ","tooltip":"Rotation Locked\nClick to unlock auto-rotation","class":"locked"}'
    else
        echo '{"text":" ","tooltip":"Rotation Unlocked\nClick to lock current orientation","class":"unlocked"}'
    fi
  '';
in
{
  options.custom.system.displayManagement = {
    enable = mkEnableOption "display management tools and utilities";
    
    tools = {
      wlrRandr = mkOption {
        type = types.bool;
        default = true;
        description = "Enable wlr-randr for CLI display configuration";
      };
      
      wdisplays = mkOption {
        type = types.bool;
        default = true;
        description = "Enable wdisplays GUI for display configuration";
      };
      
      kanshi = mkOption {
        type = types.bool;
        default = true;
        description = "Enable kanshi for automatic display profiles";
      };
    };
    
    autoRotate = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable multi-monitor auto-rotation";
      };
      
      syncExternal = mkOption {
        type = types.bool;
        default = true;
        description = "Sync external monitor rotation with built-in display";
      };
      
      externalPosition = mkOption {
        type = types.enum [ "right" "left" "above" "below" ];
        default = "right";
        description = "Default position of external monitor";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install display management tools
    environment.systemPackages = with pkgs; 
      (optional cfg.tools.wlrRandr wlr-randr) ++
      (optional cfg.tools.wdisplays wdisplays) ++
      (optional cfg.tools.kanshi kanshi) ++
      [ 
        wayland-utils  # Always include for debugging
        rotation-lock-toggle  # Rotation lock toggle script
        rotation-lock-status  # Rotation lock status script
      ];

    # Display management aliases
    environment.shellAliases = {
      # List displays
      displays = "wlr-randr";
      display-info = "wayland-info | grep -A 10 'wl_output'";
      
      # Quick display presets
      laptop-only = "wlr-randr --output HDMI-A-1 --off --output DSI-1 --on --scale 1.5 --transform 3";
      external-only = "wlr-randr --output DSI-1 --off --output HDMI-A-1 --on --scale 1";
      dual-displays = "wlr-randr --output DSI-1 --on --scale 1.5 --transform 3 --output HDMI-A-1 --on --scale 1 --pos 1280,0";
      
      # Rotation commands for GPD Pocket 3
      rotate-landscape = "wlr-randr --output DSI-1 --transform 3";  # 270° for GPD
      rotate-portrait = "wlr-randr --output DSI-1 --transform 0";
      rotate-landscape-inverted = "wlr-randr --output DSI-1 --transform 1";  # 90°
      rotate-portrait-inverted = "wlr-randr --output DSI-1 --transform 2";  # 180°
      
      # Sync rotation commands (both displays)
      both-landscape = "wlr-randr --output DSI-1 --transform 3 --output HDMI-A-1 --transform 3";
      both-portrait = "wlr-randr --output DSI-1 --transform 0 --output HDMI-A-1 --transform 0";
      
      # External monitor positioning
      hdmi-left = "wlr-randr --output HDMI-A-1 --pos 0,0 --output DSI-1 --pos 2560,0";
      hdmi-right = "wlr-randr --output HDMI-A-1 --pos 1280,0 --output DSI-1 --pos 0,0";
      hdmi-above = "wlr-randr --output HDMI-A-1 --pos 0,0 --output DSI-1 --pos 640,1440";
      hdmi-below = "wlr-randr --output HDMI-A-1 --pos 640,1280 --output DSI-1 --pos 0,0";
      
      # Reset to defaults
      display-reset = "wlr-randr --output DSI-1 --on --scale 1.5 --transform 3 --pos 0,0 --output HDMI-A-1 --on --scale 1 --pos 1280,0 --transform 0";
      
      # Rotation lock
      rotation-lock = "rotation-lock-toggle";
    };

    # Configure the enhanced multi-monitor auto-rotation if enabled
    custom.system.hardware.autoRotateMulti = mkIf cfg.autoRotate.enable {
      enable = true;
      primaryMonitor = "DSI-1";
      scale = 1.5;
      externalScale = 1.0;
      syncRotation = cfg.autoRotate.syncExternal;
      externalPosition = cfg.autoRotate.externalPosition;
    };
  };
}
