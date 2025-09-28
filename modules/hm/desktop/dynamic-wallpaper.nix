{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.dynamicWallpaper;
in
{
  options.custom.hm.dynamicWallpaper = {
    enable = mkEnableOption "Dynamic live-rendered wallpaper system";

    cycleInterval = mkOption {
      type = types.int;
      default = 15;
      description = "Seconds between wallpaper changes";
    };

    colors = mkOption {
      type = types.listOf types.str;
      default = [ "#ff6b6b" "#4ecdc4" "#45b7d1" "#96ceb4" "#ffeaa7" "#dda0dd" ];
      description = "Color palette for dynamic wallpaper cycling";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.dynamic-wallpaper = {
      Unit = {
        Description = "Dynamic live wallpaper for GPD Pocket 3";
        After = [ "hyprland-session.target" ];
        Wants = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = pkgs.writeShellScript "dynamic-wallpaper" ''
          #!/usr/bin/env bash
          set -euo pipefail

          # Wait for SWWW daemon
          while ! ${pkgs.swww}/bin/swww query >/dev/null 2>&1; do
            sleep 1
          done

          echo "🌊 Starting dynamic wallpaper cycling..."

          # Color cycling loop
          colors=(${toString cfg.colors})
          color_index=0

          while true; do
            current_color="''${colors[$color_index]}"

            # Create dynamic gradient image
            ${pkgs.imagemagick}/bin/convert -size 1920x1080 \
              -define gradient:vector=45,45,1875,1035 \
              gradient:"$current_color"-"#000000" \
              /tmp/dynamic_wallpaper_''${color_index}.png

            # Apply wallpaper with smooth transition
            ${pkgs.swww}/bin/swww img "/tmp/dynamic_wallpaper_''${color_index}.png" \
              --transition-type fade --transition-duration 2 >/dev/null 2>&1 || true

            # Cycle to next color
            color_index=$(( (color_index + 1) % ''${#colors[@]} ))

            sleep ${toString cfg.cycleInterval}
          done
        '';
        Restart = "always";
        RestartSec = 5;
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

    # Ensure swww is available
    home.packages = with pkgs; [ swww imagemagick ];
  };
}