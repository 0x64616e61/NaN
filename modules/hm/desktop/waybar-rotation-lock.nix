{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.waybarRotationLock;
in
{
  options.custom.hm.desktop.waybarRotationLock = {
    enable = mkEnableOption "waybar rotation lock button";
  };

  config = mkIf cfg.enable {
    # Create the waybar module configuration
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
