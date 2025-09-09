{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.waybarRotationPatch;
  
  # Script to add rotation lock to waybar config
  patchWaybarConfig = pkgs.writeShellScriptBin "patch-waybar-config" ''
    CONFIG="$HOME/.config/waybar/config.jsonc"
    MODULE_FILE="$HOME/.config/waybar/modules/custom-rotation-lock.jsonc"
    
    # Wait for config to exist
    for i in {1..10}; do
      [ -f "$CONFIG" ] && break
      sleep 1
    done
    
    # Add rotation-lock after privacy if not already present
    if [ -f "$CONFIG" ] && ! grep -q "custom/rotation-lock" "$CONFIG"; then
      sed -i 's/"privacy",/"privacy",\n            "custom\/rotation-lock",/' "$CONFIG"
    fi
    
    # Ensure module file exists
    if [ ! -f "$MODULE_FILE" ]; then
      mkdir -p "$(dirname "$MODULE_FILE")"
      cat > "$MODULE_FILE" << ''''MODEOF''''
{
    "custom/rotation-lock": {
        "format": "{}",
        "exec": "rotation-lock-status",
        "interval": 1,
        "on-click": "rotation-lock-simple",
        "signal": 8,
        "tooltip": true,
        "tooltip-format": "Toggle rotation lock for focused display",
        "return-type": ""
    }
}
MODEOF
    fi
  ''';
in
{
  options.custom.hm.desktop.waybarRotationPatch = {
    enable = mkEnableOption "automatic waybar rotation lock button patch";
  };

  config = mkIf cfg.enable {
    # Run patch script after waybar starts
    systemd.user.services.waybar-rotation-patch = {
      Unit = {
        Description = "Add rotation lock to waybar config";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      
      Service = {
        Type = "oneshot";
        ExecStart = "${patchWaybarConfig}/bin/patch-waybar-config";
        RemainAfterExit = true;
      };
      
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    
    # Also patch on waybar restart
    systemd.user.paths.waybar-config-watcher = {
      Unit = {
        Description = "Watch for waybar config changes";
      };
      
      Path = {
        PathChanged = "/home/a/.config/waybar/config.jsonc";
      };
      
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
    
    systemd.user.services.waybar-config-watcher = {
      Unit = {
        Description = "Patch waybar config when it changes";
      };
      
      Service = {
        Type = "oneshot";
        ExecStart = "${patchWaybarConfig}/bin/patch-waybar-config";
      };
    };
  };
}
