{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.monitor;
in
{
  options.custom.system.monitor = {
    enable = mkEnableOption "system-level monitor configuration for Hyprland";

    name = mkOption {
      type = types.str;
      default = "DSI-1";
      example = "HDMI-A-1";
      description = "Monitor name/identifier (e.g., DSI-1, HDMI-A-1, DP-1)";
    };

    resolution = mkOption {
      type = types.str;
      default = "1200x1920@60";
      example = "1920x1080@144";
      description = ''
        Monitor resolution and refresh rate in format: WIDTHxHEIGHT@REFRESH
        Examples: "1920x1080@60", "2560x1440@144", "3440x1440@98"
      '';
    };

    position = mkOption {
      type = types.str;
      default = "0x0";
      example = "1920x0";
      description = ''
        Monitor position in format: X_OFFSETxY_OFFSET
        Use "0x0" for primary monitor, "1920x0" for second monitor to the right
      '';
    };

    scale = mkOption {
      type = types.addCheck types.float (x: x >= 0.5 && x <= 3.0);
      default = 1.5;
      example = 2.0;
      description = ''
        Monitor scale factor (0.5-3.0)
        Common values: 1.0 (native), 1.5 (150%), 2.0 (200%)
        Higher values make UI elements larger
      '';
    };

    transform = mkOption {
      type = types.enum [ 0 1 2 3 ];
      default = 3;
      description = ''
        Monitor rotation transform:
        0 = normal (0°)
        1 = 90° clockwise
        2 = 180° (upside down)
        3 = 270° clockwise (or 90° counter-clockwise)
      '';
    };
  };

  config = mkIf cfg.enable {
    # Validate configuration
    assertions = [
      {
        assertion = cfg.scale >= 0.5 && cfg.scale <= 3.0;
        message = "Monitor scale must be between 0.5 and 3.0, got ${toString cfg.scale}";
      }
      {
        assertion = builtins.elem cfg.transform [ 0 1 2 3 ];
        message = "Monitor transform must be 0, 1, 2, or 3, got ${toString cfg.transform}";
      }
      {
        assertion = builtins.match "[0-9]+x[0-9]+@[0-9]+" cfg.resolution != null;
        message = "Monitor resolution must be in format WIDTHxHEIGHT@REFRESH (e.g., 1920x1080@60), got: ${cfg.resolution}";
      }
      {
        assertion = builtins.match "[0-9]+x[0-9]+" cfg.position != null;
        message = "Monitor position must be in format XxY (e.g., 0x0 or 1920x0), got: ${cfg.position}";
      }
    ];
    # Create a systemd service that runs AFTER the rebuild to fix monitor orientation
    # This runs as a oneshot service after multi-user.target and home-manager
    systemd.services.fix-hyprland-monitor = {
      description = "Fix Hyprland monitor orientation after rebuild";
      after = [ "multi-user.target" "home-manager-a.service" ];
      wantedBy = [ "multi-user.target" ];
      
      # Run immediately after rebuild
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        ExecStart = pkgs.writeShellScript "fix-monitor-orientation" ''
          echo "Fixing Hyprland monitor configuration..."
          
          # Write correct monitors.conf
          for USER_HOME in /home/*; do
            if [ -d "$USER_HOME/.config/hypr" ]; then
              echo "Writing monitors.conf for $USER_HOME"
              cat > "$USER_HOME/.config/hypr/monitors.conf" <<'EOF'
# █▀▄▀█ █▀█ █▄░█ █ ▀█▀ █▀█ █▀█ █▀
# █░▀░█ █▄█ █░▀█ █ ░█░ █▄█ █▀▄ ▄█

# GPD Pocket 3 DSI display - landscape orientation
# Transform 3 = 270 degrees rotation (landscape mode)
monitor = ${cfg.name}, ${cfg.resolution}, ${cfg.position}, ${toString cfg.scale}, transform, ${toString cfg.transform}
# External monitor - ultrawide at native resolution, positioned above main display
monitor = DP-1, 3440x1440@98, 0x-1440, 1, transform, 0
# Fallback for HDMI if used
monitor = HDMI-A-1, preferred, auto, 1, transform, 0
EOF
              chown $(basename "$USER_HOME"):users "$USER_HOME/.config/hypr/monitors.conf"
              
              # Also add to workflows.conf if needed
              if [ -f "$USER_HOME/.config/hypr/workflows.conf" ]; then
                if ! grep -q "hyprctl keyword monitor" "$USER_HOME/.config/hypr/workflows.conf"; then
                  echo "" >> "$USER_HOME/.config/hypr/workflows.conf"
                  echo "# Force landscape orientation on startup for GPD Pocket 3" >> "$USER_HOME/.config/hypr/workflows.conf"  
                  echo "exec-once = sleep 1 && hyprctl keyword monitor ${cfg.name},${cfg.resolution},${cfg.position},${toString cfg.scale},transform,${toString cfg.transform}" >> "$USER_HOME/.config/hypr/workflows.conf"
                fi
              fi
            fi
          done
          
          # If Hyprland is running, apply the setting immediately
          if pgrep Hyprland > /dev/null; then
            echo "Applying landscape orientation to running Hyprland session"
            # Run as the user who owns the Hyprland process
            HYPR_USER=$(ps aux | grep "[H]yprland" | head -1 | awk '{print $1}')
            if [ -n "$HYPR_USER" ]; then
              su - "$HYPR_USER" -c "${pkgs.hyprland}/bin/hyprctl keyword monitor ${cfg.name},${cfg.resolution},${cfg.position},${toString cfg.scale},transform,${toString cfg.transform}" || true
              su - "$HYPR_USER" -c "${pkgs.hyprland}/bin/hyprctl keyword monitor DP-1,3440x1440@98,0x-1440,1,transform,0" || true
              su - "$HYPR_USER" -c "${pkgs.hyprland}/bin/hyprctl keyword monitor HDMI-A-1,preferred,auto,1,transform,0" || true
              su - "$HYPR_USER" -c "${pkgs.hyprland}/bin/hyprctl reload" || true
            fi
          fi
        '';
      };
    };
  };
}