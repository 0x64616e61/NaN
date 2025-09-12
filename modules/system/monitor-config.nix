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
      description = "Monitor name/identifier";
    };
    
    resolution = mkOption {
      type = types.str;
      default = "1200x1920@60";
      description = "Monitor resolution and refresh rate";
    };
    
    position = mkOption {
      type = types.str;
      default = "0x0";
      description = "Monitor position";
    };
    
    scale = mkOption {
      type = types.float;
      default = 1.5;
      description = "Monitor scale factor";
    };
    
    transform = mkOption {
      type = types.int;
      default = 3;
      description = "Monitor rotation (0=normal, 1=90, 2=180, 3=270)";
    };
  };

  config = mkIf cfg.enable {
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