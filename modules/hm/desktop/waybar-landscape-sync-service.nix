{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.waybarLandscapeSync;
in
{
  options.custom.hm.desktop.waybarLandscapeSync = {
    enable = mkEnableOption "waybar landscape synchronization service for GPD Pocket 3";
  };

  config = mkIf cfg.enable {
    # Reboot-safe waybar landscape sync service - ENHANCED
    systemd.user.services.waybar-landscape-sync = {
      Unit = {
        Description = "📱 Waybar Landscape Mode Synchronization (Reboot-Safe Enhanced) ✨";
        After = [ "waybar.service" "auto-rotate-both.service" "graphical-session.target" ];
        Wants = [ "waybar.service" "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5";

        # Enhanced resource management
        MemoryMax = "128M";
        CPUQuota = "20%";

        # Enhanced environment with full terminal support
        Environment = [
          "TERM=xterm-256color"
          "COLUMNS=120"
          "LINES=40"
          "HOME=%h"
          "WAYLAND_DISPLAY=wayland-1"
          "XDG_RUNTIME_DIR=/run/user/1000"
        ];

        ExecStart = let
          waybarLandscapeSyncScript = pkgs.writeShellScript "waybar-landscape-sync" ''
            #!/usr/bin/env bash
            # 📱 Waybar Landscape Sync Service - REBOOT-SAFE ENHANCED
            sys="coreutils gnugrep gnused procps waybar jq"

            echo "📱 Starting Waybar Landscape Sync Service... ✨"

            nix-shell -p $sys --run '
              CONFIG_FILE="$HOME/.config/waybar/config.jsonc"

              echo "🎯 Waybar Landscape Sync Service Started ($(date)) ✨"
              echo "📁 Configuration file: $CONFIG_FILE"

              # Enhanced function to maintain landscape positioning
              maintain_landscape() {
                  echo "🔧 Maintaining waybar landscape positioning... ✨"

                  # Ensure config file exists
                  if [ ! -f "$CONFIG_FILE" ]; then
                      echo "⚠️ Config file not found, creating directory..."
                      mkdir -p "$(dirname "$CONFIG_FILE")"
                      echo "{}" > "$CONFIG_FILE"
                  fi

                  # Always keep waybar at top for landscape UX with enhanced patterns
                  sed -i '\''s/"layer": "[^"]*"/"layer": "top"/g; s/"position": "[^"]*"/"position": "top"/g'\'' "$CONFIG_FILE"

                  # Check waybar process status
                  if ! pgrep waybar > /dev/null; then
                      echo "🚀 Starting waybar process..."
                      waybar &
                      sleep 2
                  else
                      echo "🔄 Reloading waybar configuration..."
                      # Send SIGUSR2 to reload waybar config
                      pkill -USR2 waybar || true
                      sleep 1
                  fi

                  echo "✅ Landscape positioning maintained 🎯"
              }

              # Wait for waybar configuration to be available
              echo "⏳ Waiting for waybar configuration..."
              for i in {1..30}; do
                  if [ -d "$HOME/.config" ]; then
                      echo "✅ Configuration directory available"
                      break
                  fi
                  echo "Waiting for config directory... ($i/30)"
                  sleep 2
              done

              # Initial setup
              echo "🎯 Performing initial landscape setup..."
              maintain_landscape

              # Monitor and maintain landscape positioning
              echo "👁️ Starting continuous landscape monitoring..."
              while true; do
                  sleep 5

                  # Enhanced status check with error handling
                  if [ -f "$CONFIG_FILE" ]; then
                      current_position=$(grep -o "\"position\": \"[^\"]*\"" "$CONFIG_FILE" | cut -d"\"" -f4 2>/dev/null || echo "unknown")

                      echo "📊 Current waybar position: $current_position"

                      if [ "$current_position" != "top" ]; then
                          echo "🔧 Restoring waybar landscape position (was: $current_position) ✨"
                          maintain_landscape
                      else
                          echo "✅ Landscape position confirmed 🎯"
                      fi
                  else
                      echo "⚠️ Config file missing, recreating..."
                      maintain_landscape
                  fi

                  # Check if waybar process is still running
                  if ! pgrep waybar > /dev/null; then
                      echo "🚨 Waybar process not found, restarting... ⚡"
                      maintain_landscape
                  fi
              done
            '
          '';
        in "${waybarLandscapeSyncScript}";

        # Security and reliability enhancements
        PrivateNetwork = false;
        NoNewPrivileges = false;
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}