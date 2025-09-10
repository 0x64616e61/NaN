{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.waybarRotationPatch;
in
{
  options.custom.hm.desktop.waybarRotationPatch = {
    enable = mkEnableOption "automatic waybar rotation lock button patch";
  };

  config = mkIf cfg.enable {
    # Create a script to patch waybar config
    home.packages = [ 
      (pkgs.writeShellScriptBin "patch-waybar-rotation" ''
        CONFIG="$HOME/.config/waybar/config.jsonc"
        
        # Add rotation-lock after privacy if not already present
        if [ -f "$CONFIG" ] && ! grep -q "custom/rotation-lock" "$CONFIG"; then
          sed -i 's/"privacy",/"privacy",\n            "custom\/rotation-lock",/' "$CONFIG"
          echo "Added rotation lock to waybar"
        fi
      '')
    ];
    
    # Ensure module file exists
    home.file.".config/waybar/modules/custom-rotation-lock.jsonc".text = ''
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
    '';
  };
}
