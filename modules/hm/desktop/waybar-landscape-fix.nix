{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.waybarLandscapeFix;
in
{
  options.custom.hm.desktop.waybarLandscapeFix = {
    enable = mkEnableOption "fix waybar orientation for landscape mode on GPD Pocket 3";
  };

  config = mkIf cfg.enable {
    # Create waybar configuration optimized for landscape orientation
    home.file.".config/waybar/config.jsonc".text = ''
      {
          "layer": "top",
          "position": "top",
          "height": 30,
          "spacing": 4,
          "margin-top": 2,
          "margin-left": 10,
          "margin-right": 10,

          // Landscape-oriented module layout
          "modules-left": [
              "hyprland/workspaces",
              "hyprland/window"
          ],
          "modules-center": [
              "clock",
              "custom/weather"
          ],
          "modules-right": [
              "pulseaudio",
              "network",
              "battery",
              "custom/rotation-lock",
              "tray"
          ],

          // Module configurations optimized for landscape
          "hyprland/workspaces": {
              "format": "{id}",
              "on-click": "activate",
              "sort-by-number": true
          },

          "hyprland/window": {
              "format": "{}",
              "separate-outputs": true,
              "max-length": 50
          },

          "clock": {
              "format": "{:%H:%M}",
              "format-alt": "{:%A, %B %d, %Y (%R)}",
              "tooltip-format": "<tt><small>{calendar}</small></tt>",
              "calendar": {
                  "mode": "year",
                  "mode-mon-col": 3,
                  "weeks-pos": "right",
                  "on-scroll": 1,
                  "format": {
                      "months": "<span color='#ffead3'><b>{}</b></span>",
                      "days": "<span color='#ecc6d9'><b>{}</b></span>",
                      "weeks": "<span color='#99ffdd'><b>W{}</b></span>",
                      "weekdays": "<span color='#ffcc66'><b>{}</b></span>",
                      "today": "<span color='#ff6699'><b><u>{}</u></b></span>"
                  }
              },
              "actions": {
                  "on-click-right": "mode",
                  "on-click-forward": "tz_up",
                  "on-click-backward": "tz_down",
                  "on-scroll-up": "shift_up",
                  "on-scroll-down": "shift_down"
              }
          },

          "battery": {
              "states": {
                  "warning": 30,
                  "critical": 15
              },
              "format": "{capacity}% {icon}",
              "format-charging": "{capacity}% ",
              "format-plugged": "{capacity}% ",
              "format-alt": "{time} {icon}",
              "format-icons": ["", "", "", "", ""]
          },

          "network": {
              "format-wifi": "{essid} ({signalStrength}%) ",
              "format-ethernet": "{ipaddr}/{cidr} ",
              "tooltip-format": "{ifname} via {gwaddr} ",
              "format-linked": "{ifname} (No IP) ",
              "format-disconnected": "Disconnected ⚠",
              "format-alt": "{ifname}: {ipaddr}/{cidr}"
          },

          "pulseaudio": {
              "format": "{volume}% {icon} {format_source}",
              "format-bluetooth": "{volume}% {icon} {format_source}",
              "format-bluetooth-muted": " {icon} {format_source}",
              "format-muted": " {format_source}",
              "format-source": "{volume}% ",
              "format-source-muted": "",
              "format-icons": {
                  "headphone": "",
                  "hands-free": "",
                  "headset": "",
                  "phone": "",
                  "portable": "",
                  "car": "",
                  "default": ["", "", ""]
              },
              "on-click": "pavucontrol"
          },

          "custom/rotation-lock": {
              "format": "{}",
              "exec": "echo '🔒'",
              "interval": 30,
              "on-click": "~/nix-modules/scripts/rotation-toggle.sh",
              "tooltip": "Toggle display rotation lock"
          },

          "custom/weather": {
              "format": "{}",
              "exec": "echo '⛅'",
              "interval": 300,
              "tooltip": false
          },

          "tray": {
              "icon-size": 18,
              "spacing": 10
          }
      }
    '';

    # Create landscape-optimized waybar CSS
    home.file.".config/waybar/style.css".text = ''
      * {
          border: none;
          border-radius: 0;
          font-family: "JetBrainsMono Nerd Font";
          font-size: 12px;
          min-height: 0;
      }

      window#waybar {
          background: rgba(43, 48, 59, 0.85);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .5s;
      }

      /* Landscape-specific styling */
      window#waybar.landscape {
          margin: 2px 10px 0 10px;
          border-radius: 8px;
      }

      #workspaces button {
          padding: 0 8px;
          background: transparent;
          color: #ffffff;
          border-bottom: 3px solid transparent;
          min-width: 30px;
      }

      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
          box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button.active {
          background: #64727D;
          border-bottom: 3px solid #ffffff;
      }

      #clock,
      #battery,
      #network,
      #pulseaudio,
      #custom-rotation-lock,
      #custom-weather {
          padding: 0 10px;
          margin: 0 2px;
          background: rgba(255, 255, 255, 0.1);
          border-radius: 6px;
      }

      #battery.charging, #battery.plugged {
          color: #26A65B;
          background-color: rgba(38, 166, 91, 0.1);
      }

      #battery.critical:not(.charging) {
          background-color: rgba(238, 82, 83, 0.2);
          color: #ee5253;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      @keyframes blink {
          to {
              background-color: rgba(255, 255, 255, 0.1);
              color: #ffffff;
          }
      }

      #network.disconnected {
          color: #f53c3c;
      }

      #pulseaudio.muted {
          color: #90b1b1;
      }

      #window {
          padding: 0 10px;
          font-weight: bold;
          max-width: 200px;
          overflow: hidden;
          text-overflow: ellipsis;
      }

      #tray {
          background-color: rgba(255, 255, 255, 0.1);
          border-radius: 6px;
          padding: 0 6px;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
      }
    '';

    # Create landscape orientation detection and application script - REBOOT-SAFE
    home.packages = [
      (pkgs.writeShellScriptBin "apply-waybar-landscape" ''
        #!/usr/bin/env bash
        # 📱 Waybar landscape orientation fix - REBOOT-SAFE
        sys="hyprland coreutils jq procps"

        echo "🔧 Applying waybar landscape orientation fix... ✨"

        # Get current monitor transform with reboot-safe execution
        TRANSFORM=$(nix-shell -p $sys --run "hyprctl monitors -j | jq -r '.[] | select(.name == \"DSI-1\") | .transform'")

        echo "🔄 Current display transform: $TRANSFORM"

        # Apply landscape-specific class to waybar
        if [ "$TRANSFORM" = "3" ] || [ "$TRANSFORM" = "1" ]; then
            echo "📱 Portrait transform detected ($TRANSFORM), applying landscape waybar config ✨"

            # Restart waybar with landscape configuration
            nix-shell -p $sys --run "pkill waybar 2>/dev/null || true"
            nix-shell -p $sys --run "sleep 1"

            # Start waybar in landscape mode
            echo "🚀 Starting waybar in landscape mode..."
            nix-shell -p $sys --run "waybar --class='landscape' &"

            echo "✅ Waybar restarted in landscape mode 🎯"
        else
            echo "🖥️ Landscape transform detected ($TRANSFORM), using standard config ✨"
            nix-shell -p $sys --run "pkill waybar 2>/dev/null || true"
            nix-shell -p $sys --run "sleep 1"
            nix-shell -p $sys --run "waybar &"
            echo "✅ Standard waybar configuration applied 🎯"
        fi
      '')
    ];

    # Service to automatically apply landscape fix - REBOOT-SAFE
    systemd.user.services.waybar-landscape-monitor = {
      Unit = {
        Description = "📱 Monitor display orientation and apply waybar landscape fix (Reboot-Safe) ✨";
        After = [ "hyprland-session.target" "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        Wants = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "simple";
        Restart = "always";
        RestartSec = "5";

        # Enhanced resource management
        MemoryMax = "128M";
        CPUQuota = "20%";

        # REBOOT-SAFE execution with dynamic system variables
        ExecStart = pkgs.writeShellScript "waybar-landscape-monitor" ''
          #!/usr/bin/env bash
          # 📱 Waybar landscape monitor service - REBOOT-SAFE
          sys="hyprland coreutils jq procps"

          echo "📱 Starting waybar landscape orientation monitor... ✨"

          # Wait for Hyprland to be ready
          nix-shell -p $sys --run '
            for i in {1..30}; do
              if hyprctl version >/dev/null 2>&1; then
                echo "🔄 Hyprland connection established"
                break
              fi
              echo "Waiting for Hyprland... ($i/30)"
              sleep 2
            done
          '

          while true; do
            # Check if display transform changed using reboot-safe execution
            CURRENT_TRANSFORM=$(nix-shell -p $sys --run "hyprctl monitors -j | jq -r '.[] | select(.name == \"DSI-1\") | .transform' 2>/dev/null || echo '0'")

            echo "🔄 Current transform: $CURRENT_TRANSFORM"

            # Apply appropriate waybar configuration
            if [ "$CURRENT_TRANSFORM" = "3" ] || [ "$CURRENT_TRANSFORM" = "1" ]; then
              # Portrait mode - restart waybar for landscape
              if ! nix-shell -p $sys --run "pgrep -f 'waybar.*landscape' > /dev/null"; then
                echo "📱 Switching to landscape waybar mode... ✨"
                nix-shell -p $sys --run "pkill waybar 2>/dev/null || true"
                nix-shell -p $sys --run "sleep 1"
                nix-shell -p $sys --run "waybar --class='landscape' &"
                echo "✅ Landscape waybar activated 🎯"
              fi
            else
              # Landscape mode - use standard waybar
              if ! nix-shell -p $sys --run "pgrep -f 'waybar' > /dev/null" || nix-shell -p $sys --run "pgrep -f 'waybar.*landscape' > /dev/null"; then
                echo "🖥️ Switching to standard waybar mode... ✨"
                nix-shell -p $sys --run "pkill waybar 2>/dev/null || true"
                nix-shell -p $sys --run "sleep 1"
                nix-shell -p $sys --run "waybar &"
                echo "✅ Standard waybar activated 🎯"
              fi
            fi

            nix-shell -p $sys --run "sleep 5"
          done
        '';

        # Enhanced environment with terminal support
        Environment = [
          "TERM=xterm-256color"
          "COLUMNS=120"
          "LINES=40"
          "WAYLAND_DISPLAY=wayland-1"
          "XDG_RUNTIME_DIR=/run/user/1000"
        ];

        # Security and reliability
        PrivateNetwork = false;
        NoNewPrivileges = false;
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };
  };
}